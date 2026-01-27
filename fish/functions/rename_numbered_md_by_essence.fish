function rename_numbered_md_by_essence --description "使用 Fabric 提取 [0-9].md 文件的本質並重新命名"
    # 🕵️ 使用 command ls -1 確保只拿到「純檔名」，不受 alias 影響
    # 只過濾出像 1.md, 2.md 這種純數字開頭的檔案
    set -l targets (command ls -1 | grep -E '^[0-9]+\.md$')

    # 🛑 錯誤處理：沒找到檔案
    if test (count $targets) -eq 0
        echo "🚫 找不到任何純數字命名的 .md 檔案 (如 1.md)！"
        echo "📂 目前目錄：(pwd)"
        echo "ℹ️  如果檔案已經改過名 (如 1-精華.md)，本腳本會自動跳過。"
        return 1
    end

    echo "🚀 發現 (count $targets) 個檔案，開始執行本質蒸餾..."

    for file in $targets
        # 🔢 提取數字部分
        set -l num (string replace ".md" "" "$file")
        
        echo "🧪 正在分析: $file ..."

        # 🤖 呼叫 Fabric 模式：extract_10_word_essence
        # 2>/dev/null 防止錯誤訊息弄亂畫面，string trim 移除換行與空白
        set -l essence (cat "$file" | fabric -p extract_10_word_essence 2>/dev/null | string trim)

        if test -n "$essence"
            # 🧹 檔名安全清理：移除斜線防止路徑解析錯誤，並把換行轉成空格
            set -l clean_essence (string replace -a " " "_" "$essence" | string replace -a "/" "-")

            # 📝 產出新檔名：數字-精華.md
            set -l new_name "$num-$clean_essence.md"
            
            # 🚚 執行更名
            if mv "$file" "$new_name"
                echo "✅ 成功：$file ➜ $new_name"
            else
                echo "❌ 失敗：無法重新命名 $file"
            end
        else
            echo "⚠️  跳過：$file 提取內容為空"
        end
    end

    echo "✨ 任務完成！你的目錄現在看起來很專業了。"
end
