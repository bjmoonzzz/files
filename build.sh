#!/bin/bash

# 配置部分
DOWNLOAD_DIR="./downloads"
OUTPUT_FILE="index.html"
TITLE="文件"

# 1. 写入 HTML 头部 (包含 CSS 样式)
cat > "$OUTPUT_FILE" <<EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$TITLE</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; max-width: 800px; margin: 2rem auto; padding: 0 1rem; background: #f9f9f9; color: #333; }
        .container { background: white; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); padding: 20px; }
        h1 { text-align: center; margin-bottom: 20px; font-size: 1.5rem; }
        ul { list-style: none; padding: 0; margin: 0; }
        li { border-bottom: 1px solid #eee; padding: 12px 0; display: flex; align-items: center; justify-content: space-between; }
        li:last-child { border-bottom: none; }
        a { text-decoration: none; color: #0366d6; font-weight: 500; font-size: 1rem; flex-grow: 1; margin-right: 10px; word-break: break-all; }
        a:hover { text-decoration: underline; }
        .size { color: #888; font-size: 0.85rem; white-space: nowrap; background: #f0f0f0; padding: 2px 6px; border-radius: 4px; }
        .empty { text-align: center; color: #999; padding: 20px; }
        footer { margin-top: 20px; text-align: center; font-size: 0.8rem; color: #aaa; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📂 $TITLE</h1>
        <ul>
EOF

# 2. 循环扫描 downloads 文件夹
# 检查文件夹是否存在
if [ -d "$DOWNLOAD_DIR" ]; then
    # 查找文件，排除隐藏文件(如 .DS_Store)，按文件名排序
    # 注意：为了处理文件名中的空格，我们改变 IFS 变量
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    
    has_file=false
    
    for filepath in $(ls "$DOWNLOAD_DIR" | sort); do
        # 排除隐藏文件
        if [[ "$filepath" == .* ]]; then continue; fi
        
        full_path="$DOWNLOAD_DIR/$filepath"
        
        # 确保是文件而不是文件夹
        if [ -f "$full_path" ]; then
            has_file=true
            filename=$(basename "$full_path")
            
            # 获取文件大小 (兼容 Mac 和 Linux 的 du 命令)
            # du -h 输出如 "2.5M    ./downloads/file.zip"，我们只取第一列
            filesize=$(du -h "$full_path" | cut -f1)
            
            # URL 编码处理 (简单的空格处理)
            # 浏览器通常能自动处理中文，但空格必须转义为 %20，这里用 sed 简单替换
            # 注意：如果文件名非常复杂，建议改用 Python 脚本生成
            url_path="./downloads/$filename"
            
            # 写入列表项
            echo "            <li>" >> "$OUTPUT_FILE"
            echo "                <a href=\"$url_path\">$filename</a>" >> "$OUTPUT_FILE"
            echo "                <span class=\"size\">$filesize</span>" >> "$OUTPUT_FILE"
            echo "            </li>" >> "$OUTPUT_FILE"
            
            echo "已添加: $filename ($filesize)"
        fi
    done
    
    if [ "$has_file" = false ]; then
        echo "            <li class='empty'>暂无文件</li>" >> "$OUTPUT_FILE"
    fi
    
    IFS=$SAVEIFS
else
    echo "警告: $DOWNLOAD_DIR 文件夹不存在！"
    echo "            <li class='empty'>下载目录不存在</li>" >> "$OUTPUT_FILE"
fi

# 3. 写入 HTML 尾部
cat >> "$OUTPUT_FILE" <<EOF
        </ul>
    </div>
</body>
</html>
EOF

echo "✅ index.html 生成完毕！"
