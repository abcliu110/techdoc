#!/bin/bash
# check-level1-skeleton.sh
# 用途：校验 Level 1 骨架完整性和内容实质性
# 退出码：
#   0 - 所有业务域骨架齐全且含实质内容
#   2 - Level 1 目录存在但骨架缺失或被误删
#   3 - Level 2 任务所属业务域未在 Level 0 清单或无 Level 1 骨架
#   4 - 业务域清单与 Level 1 目录不一致
#   5 - Level 1 文件存在但内容全为模板占位符

set -euo pipefail

ROOT_PATH="${1:-系统分析产出}"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 辅助函数：检查文件是否只含模板占位符
is_placeholder_only() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    # 移除 skeleton 标记行，检查剩余内容
    local content
    content=$(grep -v '^\s*<!--\s*skeleton:.*-->\s*$' "$file" || true)
    
    # 检查是否只含占位符
    local substantive
    substantive=$(echo "$content" | grep -v '^\s*$' | \
                  grep -v '^\s*-\s*$' | \
                  grep -v '^\s*待补充' | \
                  grep -v '^\s*待分析' | \
                  grep -v '^\s*TODO' | \
                  grep -v '^\s*\[.*\]\s*$' | \
                  grep -v '^\s*#\+\s*$' || true)
    
    if [[ -z "$substantive" ]]; then
        return 0  # 仅含占位符
    else
        return 1  # 含实质内容
    fi
}

echo -e "${CYAN}=== Level 1 骨架完整性检查 ===${NC}"
echo "根路径: $ROOT_PATH"
echo ""

# 1. 读取 Level 0 业务域清单
LEVEL0_DIR="$ROOT_PATH/Level 0"
# Find the file by pattern to avoid hardcoding Chinese characters
MODULE_FILE=$(find "$LEVEL0_DIR" -maxdepth 1 -name "02-*.md" -type f | head -1)

if [[ ! -f "$MODULE_FILE" ]]; then
    echo -e "${RED}[错误] 未找到业务域清单文件（期望 02-*.md）在: $LEVEL0_DIR${NC}"
    exit 4
fi

echo -e "${YELLOW}[1/5] 解析业务域清单...${NC}"

# 提取业务域定义
declare -a DOMAINS
declare -a DOMAIN_NUMBERS
declare -a DOMAIN_NAMES
declare -a DOMAIN_IDS
declare -a DOMAIN_FULLNAMES

while IFS= read -r line; do
    if [[ $line =~ 业务域([0-9]{2})-([^(]+)\(([^)]+)\) ]]; then
        num="${BASH_REMATCH[1]}"
        name=$(echo "${BASH_REMATCH[2]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        domain=$(echo "${BASH_REMATCH[3]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        fullname="业务域${num}-${name}(${domain})"
        
        DOMAIN_NUMBERS+=("$num")
        DOMAIN_NAMES+=("$name")
        DOMAIN_IDS+=("$domain")
        DOMAIN_FULLNAMES+=("$fullname")
    fi
done < "$MODULE_FILE"

DOMAIN_COUNT=${#DOMAIN_FULLNAMES[@]}

if [[ $DOMAIN_COUNT -eq 0 ]]; then
    echo -e "${RED}[错误] 未在 $MODULE_FILE 中找到业务域定义${NC}"
    exit 4
fi

echo -e "  ${GREEN}找到 $DOMAIN_COUNT 个业务域${NC}"

# 2. 校验业务域编号连续且不重复
echo ""
echo -e "${YELLOW}[2/5] 校验业务域编号...${NC}"

declare -A number_count
for num in "${DOMAIN_NUMBERS[@]}"; do
    ((number_count[$num]++)) || true
done

# 检查重复
duplicates=""
for num in "${!number_count[@]}"; do
    if [[ ${number_count[$num]} -gt 1 ]]; then
        duplicates="$duplicates $num"
    fi
done

if [[ -n "$duplicates" ]]; then
    echo -e "${RED}[错误] 业务域编号重复:$duplicates${NC}"
    exit 4
fi

# 检查连续性
sorted_numbers=($(printf '%s\n' "${DOMAIN_NUMBERS[@]}" | sort -n))
for i in "${!sorted_numbers[@]}"; do
    expected=$((i + 1))
    actual=${sorted_numbers[$i]#0}  # 移除前导0
    if [[ $actual -ne $expected ]]; then
        echo -e "${RED}[错误] 业务域编号不连续，期望 $expected，实际 $actual${NC}"
        exit 4
    fi
done

echo -e "  ${GREEN}编号连续且无重复 ✓${NC}"

# 3. 校验 Level 1 目录和骨架文件
echo ""
echo -e "${YELLOW}[3/5] 校验 Level 1 骨架...${NC}"

# Find Level 1 directory by pattern
LEVEL1_DIR=$(find "$ROOT_PATH" -maxdepth 1 -type d -name "Level 1*" | head -1)
if [[ ! -d "$LEVEL1_DIR" ]]; then
    echo -e "${RED}[错误] 未找到 Level 1 目录（期望 Level 1-*）在: $ROOT_PATH${NC}"
    exit 4
fi

# Detect required file names from existing complete domain
REQUIRED_FILES=()
for domain_dir in "$LEVEL1_DIR"/*; do
    if [[ -d "$domain_dir" ]]; then
        mapfile -t candidate_files < <(find "$domain_dir" -maxdepth 1 -name "0[1-3]-*.md" -type f | sort)
        if [[ ${#candidate_files[@]} -ge 3 ]]; then
            for file in "${candidate_files[@]}"; do
                REQUIRED_FILES+=("$(basename "$file")")
            done
            break
        fi
    fi
done

# Fallback: use pattern if we can't detect
if [[ ${#REQUIRED_FILES[@]} -eq 0 ]]; then
    REQUIRED_FILES=("01-*.md" "02-*.md" "03-*.md")
fi

SKELETON_MARKER="<!-- skeleton: do not delete -->"

declare -a missing_dirs
declare -a missing_files
declare -a missing_markers
declare -a placeholder_only

for fullname in "${DOMAIN_FULLNAMES[@]}"; do
    domain_dir="$LEVEL1_DIR/$fullname"
    
    if [[ ! -d "$domain_dir" ]]; then
        missing_dirs+=("$fullname")
        continue
    fi
    
    for file in "${REQUIRED_FILES[@]}"; do
        file_path="$domain_dir/$file"
        
        if [[ ! -f "$file_path" ]]; then
            missing_files+=("$fullname/$file")
            continue
        fi
        
        if ! grep -qF "$SKELETON_MARKER" "$file_path"; then
            missing_markers+=("$fullname/$file")
        fi
        
        if is_placeholder_only "$file_path"; then
            placeholder_only+=("$fullname/$file")
        fi
    done
done

if [[ ${#missing_dirs[@]} -gt 0 ]]; then
    echo -e "${RED}[错误] 缺失 Level 1 目录:${NC}"
    printf '%s\n' "${missing_dirs[@]}" | sed "s/^/  ${RED}- /" | sed "s/$/${NC}/"
    exit 4
fi

if [[ ${#missing_files[@]} -gt 0 ]]; then
    echo -e "${RED}[错误] 缺失骨架文件:${NC}"
    printf '%s\n' "${missing_files[@]}" | sed "s/^/  ${RED}- /" | sed "s/$/${NC}/"
    exit 2
fi

if [[ ${#missing_markers[@]} -gt 0 ]]; then
    echo -e "${YELLOW}[警告] 缺失 skeleton 标记:${NC}"
    printf '%s\n' "${missing_markers[@]}" | sed "s/^/  ${YELLOW}- /" | sed "s/$/${NC}/"
fi

if [[ ${#placeholder_only[@]} -gt 0 ]]; then
    echo -e "${RED}[错误] 内容仅含模板占位符（G1 未完成）:${NC}"
    printf '%s\n' "${placeholder_only[@]}" | sed "s/^/  ${RED}- /" | sed "s/$/${NC}/"
    exit 5
fi

echo -e "  ${GREEN}所有业务域骨架齐全且含实质内容 ✓${NC}"

# 4. 校验 Level 2 任务所属业务域
echo ""
echo -e "${YELLOW}[4/5] 校验 Level 2 任务归属...${NC}"

LEVEL2_DIR="$ROOT_PATH/Level 2"
declare -a orphaned_level2

if [[ -d "$LEVEL2_DIR" ]]; then
    while IFS= read -r -d '' context_dir; do
        context_name=$(basename "$context_dir")
        belongs_to_domain=false
        
        for fullname in "${DOMAIN_FULLNAMES[@]}"; do
            domain_dir="$LEVEL1_DIR/$fullname"
            context_list_file="$domain_dir/02-上下文清单.md"
            
            if [[ -f "$context_list_file" ]] && grep -qF "$context_name" "$context_list_file"; then
                belongs_to_domain=true
                break
            fi
        done
        
        if [[ "$belongs_to_domain" == "false" ]]; then
            orphaned_level2+=("$context_name")
        fi
    done < <(find "$LEVEL2_DIR" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null || true)
fi

if [[ ${#orphaned_level2[@]} -gt 0 ]]; then
    echo -e "${RED}[错误] Level 2 任务未在任何业务域清单中:${NC}"
    printf '%s\n' "${orphaned_level2[@]}" | sed "s/^/  ${RED}- /" | sed "s/$/${NC}/"
    exit 3
fi

echo -e "  ${GREEN}所有 Level 2 任务归属明确 ✓${NC}"

# 5. 最终汇总
echo ""
echo -e "${YELLOW}[5/5] 最终汇总${NC}"
echo -e "  ${CYAN}业务域数量: $DOMAIN_COUNT${NC}"
echo -e "  ${GREEN}Level 1 目录: $DOMAIN_COUNT/$DOMAIN_COUNT ✓${NC}"
echo -e "  ${GREEN}Level 1 文件: $((DOMAIN_COUNT * 3))/$((DOMAIN_COUNT * 3)) ✓${NC}"
echo -e "  ${GREEN}实质内容: 全部通过 ✓${NC}"

echo ""
echo -e "${GREEN}=== 检查通过 ===${NC}"
exit 0
