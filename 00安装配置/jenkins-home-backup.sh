#!/usr/bin/env bash
set -Eeuo pipefail

NAMESPACE=jenkins
STATEFULSET=jenkins
HELPER_POD=jenkins-home-maintenance
BACKUP_DIR=/var/backups/jenkins
ACTION="${1:-}"
ARCHIVE="${2:-}"

if [[ "$ACTION" != "backup" && "$ACTION" != "restore" ]]; then
  echo "Usage: $0 backup | $0 restore <archive-name>" >&2
  exit 2
fi

claim_name="$(kubectl get pvc -n "$NAMESPACE" -l app.kubernetes.io/instance=jenkins -o jsonpath='{.items[0].metadata.name}')"
test -n "$claim_name" || { echo "Jenkins PVC not found" >&2; exit 1; }
replicas="$(kubectl get statefulset "$STATEFULSET" -n "$NAMESPACE" -o jsonpath='{.spec.replicas}')"

kubectl scale statefulset "$STATEFULSET" -n "$NAMESPACE" --replicas=0
kubectl wait -n "$NAMESPACE" --for=delete pod/jenkins-0 --timeout=180s || true
kubectl delete pod "$HELPER_POD" -n "$NAMESPACE" --ignore-not-found --wait=true

cleanup() {
  kubectl delete pod "$HELPER_POD" -n "$NAMESPACE" --ignore-not-found --wait=true >/dev/null 2>&1 || true
  kubectl scale statefulset "$STATEFULSET" -n "$NAMESPACE" --replicas="$replicas" >/dev/null
}
trap cleanup EXIT

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: ${HELPER_POD}
  namespace: ${NAMESPACE}
spec:
  restartPolicy: Never
  containers:
    - name: maintenance
      image: busybox:1.37.0
      command: ["sh", "-c", "sleep 3600"]
      securityContext:
        runAsUser: 0
      volumeMounts:
        - {name: home, mountPath: /var/jenkins_home}
        - {name: backup, mountPath: /backup}
  volumes:
    - name: home
      persistentVolumeClaim: {claimName: ${claim_name}}
    - name: backup
      hostPath: {path: ${BACKUP_DIR}, type: DirectoryOrCreate}
EOF
kubectl wait -n "$NAMESPACE" --for=condition=Ready pod/"$HELPER_POD" --timeout=180s

if [[ "$ACTION" == "backup" ]]; then
  ARCHIVE="jenkins-home-$(date -u +%Y%m%dT%H%M%SZ).tar.gz"
  kubectl exec -n "$NAMESPACE" "$HELPER_POD" -- sh -c \
    "tar -czf '/backup/$ARCHIVE' -C /var/jenkins_home . && chmod 600 '/backup/$ARCHIVE' && sha256sum '/backup/$ARCHIVE' > '/backup/$ARCHIVE.sha256' && chmod 600 '/backup/$ARCHIVE.sha256'"
  kubectl exec -n "$NAMESPACE" "$HELPER_POD" -- sha256sum -c "/backup/$ARCHIVE.sha256"
  echo "Backup created outside the Jenkins PVC: $BACKUP_DIR/$ARCHIVE"
else
  [[ "${JENKINS_RESTORE_CONFIRM:-}" == "RESTORE_JENKINS_HOME" ]] || { echo "Restore confirmation missing" >&2; exit 1; }
  [[ "$ARCHIVE" =~ ^jenkins-home-[0-9]{8}T[0-9]{6}Z\.tar\.gz$ ]] || { echo "Invalid archive name" >&2; exit 1; }
  kubectl exec -n "$NAMESPACE" "$HELPER_POD" -- sha256sum -c "/backup/$ARCHIVE.sha256"
  kubectl exec -n "$NAMESPACE" "$HELPER_POD" -- sh -c \
    "find /var/jenkins_home -mindepth 1 -maxdepth 1 ! -name lost+found -exec rm -rf -- {} + && tar -xzf '/backup/$ARCHIVE' -C /var/jenkins_home && chown -R 1000:1000 /var/jenkins_home"
  echo "Jenkins Home restored from: $BACKUP_DIR/$ARCHIVE"
fi
