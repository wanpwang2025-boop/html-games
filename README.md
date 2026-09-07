# 🎮 HTML Games

免安裝・單檔 HTML5 小遊戲合集。直接用瀏覽器開啟就能玩，最佳成績存在 `localStorage`。

**線上玩：** https://wanpwang1981-ux.github.io/html-games/ （推上 GitHub 後開 Pages 即生效）

## 遊戲一覽

| 遊戲 | 檔案 | 玩法 |
|---|---|---|
| 🐦 憤怒鳥大作戰 | `angry-birds.html` | 拉弓彈射，消滅綠豬。3 關＋無限隨機關 |
| 🏰 魔法守塔戰 | `tower-defense.html` | 蓋塔＋合成＋屬性相剋，撐過 12 波 |
| 🧛 午夜倖存者 | `survivor.html` | Survivor-like：走位＋自動武器＋撿寶石升級，每 60 秒一隻 BOSS |
| 🦛 河馬水中芭蕾 | `hippo-water-ballet.html` | Three.js 3D 跳水＋水花物理展示（需網路載入 CDN） |

`index.html` 是大廳頁，會讀取各遊戲的最佳成績。

## 本機遊玩

```sh
# 直接雙擊 index.html，或跑個靜態伺服器：
python -m http.server 8000
# → http://localhost:8000/
```

## 存檔 key（`localStorage`）

`hg-angry-best`・`hg-angry-level`・`hg-tower-best`・`hg-tower-wave`・
`hg-survivor-best`・`hg-survivor-kills`・`hg-hippo-best`

## 參考的開源 repo

- [prateek121/90s-games](https://github.com/prateek121/90s-games) — 114 個單檔遊戲＋大廳＋`localStorage`，本專案結構即仿此
- [ricardo-foundry/canvas-vampire-survivors](https://github.com/ricardo-foundry/canvas-vampire-survivors) — 零依賴倖存者，玩法參考
- [Mihailazvfx/vampire-survivor-game](https://github.com/Mihailazvfx/vampire-survivor-game) — 單檔＋手機搖桿
- [magejosh/one-page-games](https://github.com/magejosh/one-page-games) — 單頁遊戲合集＋Pages 範例
