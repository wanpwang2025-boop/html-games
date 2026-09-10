# 🎮 HTML Games

免安裝・單檔 HTML5 小遊戲合集。直接用瀏覽器開啟就能玩，最佳成績存在 `localStorage`。

**線上玩：** https://wanpwang2025-boop.github.io/html-games/

各遊戲直連（把網址傳給朋友就能玩，免安裝）：

| 遊戲 | 連結 |
|---|---|
| 🎮 大廳 | https://wanpwang2025-boop.github.io/html-games/ |
| 🐦 憤怒鳥大作戰 | https://wanpwang2025-boop.github.io/html-games/angry-birds.html |
| 🏰 魔法守塔戰 | https://wanpwang2025-boop.github.io/html-games/tower-defense.html |
| 🧛 午夜倖存者 | https://wanpwang2025-boop.github.io/html-games/survivor.html |
| 🏯 華容道 | https://wanpwang2025-boop.github.io/html-games/huarongdao.html |
| 🏃 小朋友下樓梯 | https://wanpwang2025-boop.github.io/html-games/falldown.html |
| 🦛 河馬水中芭蕾 | https://wanpwang2025-boop.github.io/html-games/hippo-water-ballet.html |

> 注意：最佳成績存在「當下那台裝置的瀏覽器」（`localStorage`），換手機/電腦或開無痕不會同步；
> 只有倖存者能上傳全球榜。河馬芭蕾需網路載入 Three.js CDN 才能顯示 3D。

## 遊戲一覽

| 遊戲 | 檔案 | 玩法 |
|---|---|---|
| 🐦 憤怒鳥大作戰 | `angry-birds.html` | 拉弓彈射，消滅綠豬。3 關＋無限隨機關 |
| 🏰 魔法守塔戰 | `tower-defense.html` | 蓋塔＋合成＋屬性相剋，撐過 12 波 |
| 🧛 午夜倖存者 | `survivor.html` | Survivor-like：走位＋自動武器＋撿寶石升級，每 60 秒一隻 BOSS |
| 🏯 華容道 | `huarongdao.html` | Klotski 滑塊益智：12 經典棋譜（橫刀立馬→峰迴路轉），每關附電腦實測最優步數＋三星評價，另有 💡提示 / ▶自動解題 |
| 🏃 小朋友下樓梯 | `falldown.html` | NS-Shaft like：左右移動往下跳，5 種地板＋血量＋隨深度加速。玩法參考 iPel/NS-SHAFT |
| 🦛 河馬水中芭蕾 | `hippo-water-ballet.html` | Three.js 3D 跳水＋水花物理展示（需網路載入 CDN）。可放入圖片分析（明亮/飽和/動感/暖冷＋5 色票）產生專屬主題秀，另有海洋/落日/星空/櫻花 4 預設 |

`index.html` 是大廳頁，會讀取各遊戲的最佳成績。

## 本機遊玩

```sh
# 直接雙擊 index.html，或跑個靜態伺服器：
python -m http.server 8000
# → http://localhost:8000/
```

## 更新上線（把改動推上網路玩）

```sh
cd game
git add -A && git commit -m "說明" && git push
```

- GitHub Pages 會自動重建，約 1–2 分鐘生效；若看到舊畫面，開無痕視窗再驗
- 首次開通 Pages：repo → Settings → Pages → Deploy from branch → `main` / `/ (root)`
- 詳細流程（含 `gh` 指令、Supabase 全球榜設定）見 `MANUAL.md` 第 7–8 章

## 存檔 key（`localStorage`）

`hg-angry-best`・`hg-angry-level`・`hg-tower-best`・`hg-tower-wave`・
`hg-survivor-best`・`hg-survivor-kills`・`hg-survivor-board`（倖存者前 10 名榮譽榜）・`hg-survivor-name`（上傳用暱稱）・`hg-hippo-best`・`hg-hippo-theme`（河馬主題秀 JSON）・`hg-huarong-bests`（華容道每關最少步 JSON）・`hg-huarong-level`・`hg-fall-best`（下樓梯最深層數）

## 全球榜（Supabase）

倖存者結算可上傳到 Supabase `scores` 表（`time/kills/level/name`），RLS 只開公開讀＋寫入，
外加 CHECK 擋亂填。前端用 publishable key 直連 REST，無後端程式。

## 參考的開源 repo

- [prateek121/90s-games](https://github.com/prateek121/90s-games) — 114 個單檔遊戲＋大廳＋`localStorage`，本專案結構即仿此
- [ricardo-foundry/canvas-vampire-survivors](https://github.com/ricardo-foundry/canvas-vampire-survivors) — 零依賴倖存者，玩法參考
- [Mihailazvfx/vampire-survivor-game](https://github.com/Mihailazvfx/vampire-survivor-game) — 單檔＋手機搖桿
- [magejosh/one-page-games](https://github.com/magejosh/one-page-games) — 單頁遊戲合集＋Pages 範例
