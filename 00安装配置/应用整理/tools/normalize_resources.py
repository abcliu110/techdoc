#!/usr/bin/env python3
"""Build clean, static Kubernetes bundles from exported Deployment YAML files."""

from __future__ import annotations

import copy
import json
import re
from pathlib import Path

import yaml


SOURCE = Path(r"D:\resources (1)\resources")
ROOT = Path(r"D:\mywork\techdoc\00安装配置\应用整理")
BASE = ROOT / "base"

RUNTIME_META = {
    "annotations",
    "creationTimestamp",
    "deletionGracePeriodSeconds",
    "deletionTimestamp",
    "finalizers",
    "generateName",
    "generation",
    "managedFields",
    "ownerReferences",
    "resourceVersion",
    "selfLink",
    "uid",
}
RUNTIME_ANNOTATION_PREFIXES = (
    "field.cattle.io/",
    "objectset.rio.cattle.io/",
    "deployment.kubernetes.io/",
)
SENSITIVE_ENV = re.compile(r"(?:PASSWORD|PASSWD|PWD|TOKEN|SECRET|PRIVATE_KEY)", re.I)
ALREADY_PRESENT = {
    "mysql",
    "nacos",
    "harbor-core",
    "harbor-jobservice",
    "harbor-nginx",
    "harbor-portal",
    "harbor-registry",
    "jenkins",
    "nexus",
    "local-path-provisioner",
}
DEFAULT_ZERO_REPLICAS = {
    "nms4cloud-coupon-mock",
    "nms4cloud-pos11report",
    "nms4cloud-pos5sync",
    "nms4cloud-pos8book",
    "nms4cloud-pos9cash",
    "yd4cloud-capital",
    "yd4cloud-nms",
}
EXCLUDED_APPLICATIONS = {"kafka"}


def group_for(name: str, filename: str) -> str:
    if name in {"mysql", "redis", "clickhouse"}:
        return "data"
    if name in {"kafka", "zookeeper", "rocketmq-broker", "rocketmq-console", "rocketmq-nameserver", "emqx-54"}:
        return "messaging"
    if name in {"harbor-core", "harbor-jobservice", "harbor-nginx", "harbor-portal", "harbor-registry", "jenkins", "nexus", "xxl-job"}:
        return "platform"
    if name == "local-path-provisioner":
        return "cluster"
    return "business"


def resource_profile(app_name: str, container: dict, init: bool = False) -> dict:
    if init:
        return {"requests": {"cpu": "10m", "memory": "16Mi"}, "limits": {"cpu": "50m", "memory": "64Mi"}}
    image = str(container.get("image", ""))
    name = str(container.get("name", ""))
    if app_name == "clickhouse":
        return {"requests": {"cpu": "250m", "memory": "512Mi"}, "limits": {"cpu": "1", "memory": "1Gi"}}
    if app_name == "mysql" or "mysql" in image:
        return {"requests": {"cpu": "250m", "memory": "512Mi"}, "limits": {"cpu": "750m", "memory": "1536Mi"}}
    if app_name == "nacos" and name == "nacos":
        return {"requests": {"cpu": "200m", "memory": "768Mi"}, "limits": {"cpu": "750m", "memory": "1Gi"}}
    if app_name == "redis":
        return {"requests": {"cpu": "50m", "memory": "128Mi"}, "limits": {"cpu": "250m", "memory": "384Mi"}}
    if app_name in {"kafka", "rocketmq-broker", "rocketmq-console", "rocketmq-nameserver", "zookeeper", "emqx-54"}:
        profiles = {
            "kafka": ("150m", "512Mi", "500m", "1Gi"),
            "rocketmq-broker": ("250m", "512Mi", "500m", "1Gi"),
            "rocketmq-console": ("100m", "256Mi", "300m", "512Mi"),
            "rocketmq-nameserver": ("100m", "256Mi", "300m", "512Mi"),
            "zookeeper": ("100m", "128Mi", "250m", "384Mi"),
            "emqx-54": ("100m", "256Mi", "500m", "768Mi"),
        }
        cpu_req, mem_req, cpu_lim, mem_lim = profiles[app_name]
        return {"requests": {"cpu": cpu_req, "memory": mem_req}, "limits": {"cpu": cpu_lim, "memory": mem_lim}}
    if app_name in {"jenkins", "nexus"}:
        if app_name == "jenkins":
            return {"requests": {"cpu": "250m", "memory": "512Mi"}, "limits": {"cpu": "1", "memory": "1536Mi"}}
        return {"requests": {"cpu": "250m", "memory": "768Mi"}, "limits": {"cpu": "1", "memory": "1536Mi"}}
    if app_name.startswith("harbor-"):
        profiles = {
            "harbor-core": ("200m", "256Mi", "500m", "512Mi"),
            "harbor-jobservice": ("100m", "128Mi", "300m", "384Mi"),
            "harbor-nginx": ("50m", "64Mi", "250m", "256Mi"),
            "harbor-portal": ("50m", "64Mi", "250m", "256Mi"),
            "harbor-registry": ("200m", "256Mi", "500m", "768Mi"),
        }
        cpu_req, mem_req, cpu_lim, mem_lim = profiles[app_name]
        if app_name == "harbor-registry" and name == "registryctl":
            cpu_req, mem_req, cpu_lim, mem_lim = "25m", "32Mi", "100m", "128Mi"
        return {"requests": {"cpu": cpu_req, "memory": mem_req}, "limits": {"cpu": cpu_lim, "memory": mem_lim}}
    if app_name == "local-path-provisioner":
        return {"requests": {"cpu": "10m", "memory": "16Mi"}, "limits": {"cpu": "50m", "memory": "64Mi"}}
    if app_name == "nginx":
        return {"requests": {"cpu": "50m", "memory": "64Mi"}, "limits": {"cpu": "250m", "memory": "256Mi"}}
    if app_name == "gateway":
        return {"requests": {"cpu": "100m", "memory": "256Mi"}, "limits": {"cpu": "500m", "memory": "512Mi"}}
    if app_name == "xxl-job":
        return {"requests": {"cpu": "100m", "memory": "256Mi"}, "limits": {"cpu": "500m", "memory": "512Mi"}}
    business_profiles = {
        "nms4cloud-platform": ("200m", "384Mi", "750m", "1Gi"),
        "nms4cloud-biz": ("150m", "384Mi", "750m", "1Gi"),
        "nms4cloud-crm": ("150m", "384Mi", "750m", "1Gi"),
        "nms4cloud-order": ("200m", "384Mi", "750m", "1Gi"),
        "nms4cloud-payment": ("150m", "320Mi", "600m", "768Mi"),
        "nms4cloud-product": ("150m", "320Mi", "600m", "768Mi"),
        "nms4cloud-mall": ("150m", "320Mi", "600m", "768Mi"),
        "nms4cloud-wms": ("150m", "320Mi", "600m", "768Mi"),
        "nms4cloud-bi": ("200m", "512Mi", "750m", "1Gi"),
        "nms4cloud-pos11report": ("100m", "256Mi", "500m", "768Mi"),
        "nms4cloud-pos4cloud": ("100m", "256Mi", "500m", "768Mi"),
        "nms4cloud-pos5sync": ("100m", "256Mi", "500m", "768Mi"),
        "nms4cloud-pos8book": ("100m", "256Mi", "500m", "768Mi"),
        "nms4cloud-pos9cash": ("100m", "256Mi", "500m", "768Mi"),
        "nms4cloud-wechat": ("100m", "256Mi", "500m", "768Mi"),
        "nms4cloud-mq": ("150m", "320Mi", "750m", "1Gi"),
        "nms4cloud-netty": ("150m", "256Mi", "750m", "768Mi"),
        "yd4cloud-nms": ("150m", "320Mi", "750m", "1Gi"),
        "yd4cloud-capital": ("150m", "320Mi", "750m", "1Gi"),
    }
    if app_name in business_profiles:
        cpu_req, mem_req, cpu_lim, mem_lim = business_profiles[app_name]
        return {"requests": {"cpu": cpu_req, "memory": mem_req}, "limits": {"cpu": cpu_lim, "memory": mem_lim}}
    return {"requests": {"cpu": "100m", "memory": "256Mi"}, "limits": {"cpu": "500m", "memory": "768Mi"}}


def clean_metadata(metadata: dict) -> dict:
    result = {}
    for key in ("name", "namespace", "labels"):
        if key in metadata:
            result[key] = copy.deepcopy(metadata[key])
    labels = result.get("labels")
    if isinstance(labels, dict):
        result["labels"] = {
            k: v for k, v in labels.items()
            if not k.startswith("objectset.rio.cattle.io/")
        }
    return result


def secret_ref(app_name: str, env_name: str) -> dict:
    return {
        "valueFrom": {
            "secretKeyRef": {
                "name": f"{app_name}-secrets",
                "key": env_name,
            }
        }
    }


def clean_env(app_name: str, env: list[dict]) -> list[dict]:
    cleaned = []
    for item in env or []:
        current = copy.deepcopy(item)
        if "value" in current and SENSITIVE_ENV.search(str(current.get("name", ""))):
            current.pop("value", None)
            current.update(secret_ref(app_name, current["name"]))
        cleaned.append(current)
    return cleaned


def tune_jvm(app_name: str, env: list[dict]) -> list[dict]:
    values = {
        "gateway": {"JAVA_OPTS": "-Xms128m -Xmx384m"},
        "nms4cloud-coupon-mock": {"JAVA_OPTS": "-Xms128m -Xmx384m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"},
        "jenkins": {"JAVA_OPTS": "-Xmx768m -Xms256m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"},
        "nexus": {"INSTALL4J_ADD_VM_PARAMS": "-Xms384m -Xmx768m -XX:MaxDirectMemorySize=384m"},
        "nacos": {"JVM_XMS": "384m", "JVM_XMX": "384m", "JVM_XMN": "128m", "JVM_MS": "64m", "JVM_MMS": "128m"},
        "rocketmq-broker": {"JAVA_OPT_EXT": "-Xms256m -Xmx256m"},
        "rocketmq-nameserver": {"JAVA_OPT_EXT": "-Xms128m -Xmx128m"},
    }.get(app_name, {})
    for item in env:
        if item.get("name") in values:
            item["value"] = values[item["name"]]
    return env


def clean_container(app_name: str, container: dict, init: bool = False) -> dict:
    current = copy.deepcopy(container)
    if "env" in current:
        current["env"] = tune_jvm(app_name, clean_env(app_name, current["env"]))
    current["resources"] = resource_profile(app_name, current, init)
    for key in ("terminationMessagePath", "terminationMessagePolicy"):
        current.pop(key, None)
    return current


def clean_pod_spec(template_spec: dict) -> dict:
    cleaned = copy.deepcopy(template_spec)
    for key in ("dnsPolicy", "restartPolicy", "schedulerName", "terminationGracePeriodSeconds"):
        cleaned.pop(key, None)
    if cleaned.get("securityContext") == {}:
        cleaned.pop("securityContext", None)
    return cleaned


def clean_deployment(doc: dict) -> dict:
    app_name = doc["metadata"]["name"]
    cleaned = {
        "apiVersion": doc.get("apiVersion", "apps/v1"),
        "kind": doc.get("kind", "Deployment"),
        "metadata": clean_metadata(doc.get("metadata", {})),
    }
    spec = copy.deepcopy(doc.get("spec", {}))
    for key in ("progressDeadlineSeconds", "revisionHistoryLimit"):
        spec.pop(key, None)
    if app_name in DEFAULT_ZERO_REPLICAS:
        spec["replicas"] = 0
    elif spec.get("replicas") == 1:
        spec.pop("replicas", None)
    if spec.get("strategy") == {
        "type": "RollingUpdate",
        "rollingUpdate": {"maxSurge": "25%", "maxUnavailable": "25%"},
    }:
        spec.pop("strategy", None)
    template = spec.get("template", {})
    template_meta = clean_metadata(template.get("metadata", {}))
    template_spec = clean_pod_spec(template.get("spec", {}))
    template_spec["containers"] = [
        clean_container(app_name, c) for c in template_spec.get("containers", [])
    ]
    if "initContainers" in template_spec:
        template_spec["initContainers"] = [
            clean_container(app_name, c, init=True)
            for c in template_spec["initContainers"]
        ]
    template["metadata"] = template_meta
    template["spec"] = template_spec
    spec["template"] = template
    cleaned["spec"] = spec
    return cleaned


def read_documents(path: Path) -> list[dict]:
    with path.open("r", encoding="utf-8") as handle:
        return [doc for doc in yaml.safe_load_all(handle) if isinstance(doc, dict)]


def write_yaml(path: Path, document: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="\n") as handle:
        yaml.safe_dump(document, handle, allow_unicode=False, sort_keys=False, default_flow_style=False)


def kustomization(resources: list[str]) -> dict:
    return {"apiVersion": "kustomize.config.k8s.io/v1beta1", "kind": "Kustomization", "resources": resources}


def main() -> None:
    for directory in (BASE, ROOT / "bundles", ROOT / "docs"):
        directory.mkdir(parents=True, exist_ok=True)
    for app_name in EXCLUDED_APPLICATIONS:
        excluded_path = BASE / group_for(app_name, f"{app_name}.yaml") / f"{app_name}.yaml"
        excluded_path.unlink(missing_ok=True)

    inventory = []
    grouped: dict[str, list[str]] = {}
    for source in sorted(SOURCE.glob("*.yaml")):
        documents = read_documents(source)
        for doc in documents:
            if doc.get("kind") != "Deployment" or not (doc.get("metadata") or {}).get("name"):
                continue
            name = doc["metadata"]["name"]
            if name in EXCLUDED_APPLICATIONS:
                continue
            group = group_for(name, source.name)
            relative = f"base/{group}/{name}.yaml"
            write_yaml(ROOT / relative, clean_deployment(doc))
            grouped.setdefault(group, []).append(relative)
            spec = doc.get("spec", {})
            pod_spec = spec.get("template", {}).get("spec", {})
            containers = pod_spec.get("containers", [])
            inventory.append({
                "name": name,
                "namespace": doc.get("metadata", {}).get("namespace", "default"),
                "source": source.name,
                "group": group,
                "replicas": 0 if name in DEFAULT_ZERO_REPLICAS else spec.get("replicas", 1),
                "images": [c.get("image") for c in containers],
                "pvcRefs": [
                    v["persistentVolumeClaim"]["claimName"]
                    for v in pod_spec.get("volumes", [])
                    if "persistentVolumeClaim" in v
                ],
                "secretRefs": sorted({
                    ref.get("secretKeyRef", {}).get("name")
                    for c in containers + pod_spec.get("initContainers", [])
                    for env in c.get("env", [])
                    for ref in [env.get("valueFrom", {})]
                    if ref.get("secretKeyRef")
                } - {None}),
            })

    for group, resources in grouped.items():
        write_yaml(ROOT / "bundles" / f"{group}.yaml", kustomization([f"../{resource}" for resource in resources]))

    already_present = [
        f"../base/{item['group']}/{item['name']}.yaml"
        for item in inventory
        if item["name"] in ALREADY_PRESENT
    ]
    incremental = [
        f"../base/{item['group']}/{item['name']}.yaml"
        for item in inventory
        if item["name"] not in ALREADY_PRESENT and item["name"] not in DEFAULT_ZERO_REPLICAS
    ]
    default_disabled = [
        f"../base/{item['group']}/{item['name']}.yaml"
        for item in inventory
        if item["name"] in DEFAULT_ZERO_REPLICAS
    ]
    write_yaml(ROOT / "bundles" / "already-present.yaml", kustomization(sorted(already_present)))
    write_yaml(ROOT / "bundles" / "incremental.yaml", kustomization(sorted(incremental)))
    write_yaml(ROOT / "bundles" / "default-enabled.yaml", kustomization(sorted(incremental)))
    write_yaml(ROOT / "bundles" / "default-disabled.yaml", kustomization(sorted(default_disabled)))

    write_yaml(ROOT / "inventory.yaml", {"apiVersion": "codex.nms4cloud/v1", "kind": "ApplicationInventory", "applications": inventory})
    (ROOT / "docs" / "source-files.json").write_text(
        json.dumps({"source": str(SOURCE), "files": sorted(p.name for p in SOURCE.glob("*.yaml"))}, indent=2),
        encoding="utf-8",
    )
    (ROOT / "README.md").write_text(
        """# 应用整理

本目录由 `D:\\resources (1)\\resources` 的静态 Deployment 定义整理生成。原始目录不修改；本目录不包含 Kubernetes `status`、`managedFields`、UID、资源版本、创建时间或 Rancher/Cattle 运行态注解。

## 目录

- `base/`：清理后的单应用 Deployment 定义。
- `bundles/already-present.yaml`：安装基线中已有的组件，仅作定义归档，不应重复 apply。
- `bundles/incremental.yaml`：不属于安装基线的增量组件集合，仍需逐项补齐 Service、PVC、ConfigMap、Secret 和镜像来源后才能部署。
- `bundles/default-enabled.yaml`：默认启用的增量组件集合。
- `bundles/default-disabled.yaml`：默认 `replicas: 0` 的按需组件集合；应用后不会创建 Pod。
- `bundles/data.yaml`、`messaging.yaml`、`business.yaml`、`platform.yaml`：按用途拆分的静态集合。
- `inventory.yaml`：应用、镜像、PVC 和 Secret 引用清单。

## 安全约束

密码和 Token 不保存在本目录。敏感环境变量已改为 `<app>-secrets` 的 Secret 引用；Secret 必须由受控部署流程预先在目标 namespace 创建。

## 部署前必须补齐

1. 复核镜像地址和当前镜像仓库认证。
2. 为每个 PVC、ConfigMap、Secret、Service 建立独立清单。
3. 核对跨 namespace 的 MySQL/Nacos 服务地址。
4. 在低配虚拟机上按阶段启用，不能直接 apply 全部增量组件。
5. 使用 `kubectl apply --dry-run=server` 和实际回归验收。
""",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
