if not set -q NATIVE_LOCALE
    set -Ux NATIVE_LOCALE 'zh-TW'
end

if not set -q _FABRIC_USE_GEMINI_WRAPPER
    set -Ux _FABRIC_USE_GEMINI_WRAPPER 'false'
end

if test "$_FABRIC_USE_GEMINI_WRAPPER" = "true"
    if functions -q gemini-fab
        alias fabric="gemini-fab"
    end
end

function toggle_lang_output --description "Toggle Fabric LANGUAGE_OUTPUT between en-US and NATIVE_LOCALE"
    # 0. 設定檔案路徑
    set -l env_file ~/.config/fabric/.env

    if not test -f "$env_file"
        echo "❌ 錯誤: 找不到設定檔 $env_file"
        return 1
    end

    # 1. 抓取當前設定
    set -l current_lang (grep "^LANGUAGE_OUTPUT=" "$env_file" | tail -n 1 | cut -d'=' -f2)

    # 2. 核心邏輯 (直球對決：如果是 A 就切 B，否則切 A)
    # 注意：Fish 的 if block 不會隔離變數，所以裡面定義的變數外面用得到
    if test "$current_lang" = "en-US"
        # 情況一：現在是英文 -> 切換成母語
        set target_lang "$NATIVE_LOCALE"
        set icon "🇹🇼"
    else
        # 情況二：現在是母語 (或其他未知語言) -> 切換回英文
        set target_lang "en-US"
        set icon "🇺🇸"
    end

    # 3. 執行 sed (BSD/GNU 通用寫法：-i.bak 無空格)
    sed -i.bak "s/^LANGUAGE_OUTPUT=.*/LANGUAGE_OUTPUT=$target_lang/" "$env_file"

    # 4. 更新當前環境變數
    set -gx LANGUAGE_OUTPUT "$target_lang"

    echo "$icon Fabric Language switched: $current_lang ➡️  $target_lang"
end


function toggle_gemini_warp_fabric --description "Toggle Fabric Wrapper using Universal Variable"
    # 檢查當前狀態 (如果沒設定過，預設視為 false)
    if test "$_FABRIC_USE_GEMINI_WRAPPER" = "true"
        # --- 切換回 原廠模式 ---
        set -U _FABRIC_USE_GEMINI_WRAPPER "false"
        functions --erase fabric
        
        set -l color_blue (set_color blue)
        set -l color_reset (set_color normal)
        echo "$color_blue💎 Mode: Original Fabric$color_reset"
        echo "   Variable set to false. Alias removed."
        
    else
        # --- 切換成 Gemini 模式 ---
        set -U _FABRIC_USE_GEMINI_WRAPPER "true"
        alias fabric="gemini-fab"

        set -l color_green (set_color green)
        set -l color_reset (set_color normal)
        echo "$color_green💸 Mode: Gemini-Fab Wrapper$color_reset"
        echo "   Variable set to true. Alias active."
    end
end

