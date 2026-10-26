# My Music – Tài liệu thiết kế & plan triển khai

Ngày: 2026-10-23
Trạng thái: đã duyệt, giai đoạn 0–5 đã code xong (chạy thử trên Android emulator); còn giai đoạn 6 (ngày mượn Mac).

**Các câu hỏi còn mở được chốt khi triển khai (giả định, có thể đổi):**
- File nhạc có thể nằm trong "Trên iPhone" hoặc iCloud Drive. File iCloud chưa tải về được app yêu cầu iOS tải xuống, sẽ xuất hiện ở lần quét sau.
- Sau cuộc gọi / Siri / báo thức: nhạc **giữ tạm dừng**, không tự phát tiếp.
- Mã Swift chọn thư mục nằm trong `ios/Runner/AppDelegate.swift` (không tạo file mới, khỏi phải sửa project Xcode).
- Không dùng `dio`: tải YouTube qua client của `youtube_explode_dart`.

---

## 1. Mục đích

Ứng dụng nghe nhạc **cá nhân** cho iPhone 16 Pro Max, viết bằng Flutter trên project `my_music`. Chỉ một người dùng (chủ dự án), cài trực tiếp qua Xcode, **không phát hành lên App Store**.

Người dùng tự tải file mp3 từ internet về iPhone, lưu vào thư mục bất kỳ trong ứng dụng Files. App đọc và phát các file đó. Ngoài ra app nhận link YouTube để nghe phần audio mà không cần mở YouTube, và có thể tải audio đó về nghe offline.

Người dùng nghe nhạc ở mọi nơi và **tắt màn hình trong lúc nghe**, nên app phải phát nền ổn định và điều khiển được từ màn hình khóa, Control Center và nút tai nghe.

## 2. Mục tiêu / Không làm / Tránh

**Mục tiêu (goals)**
- Chọn thư mục chứa nhạc một lần, các lần sau app tự quét lại; thêm được nhiều thư mục.
- Phát nền, điều khiển từ màn hình khóa / Control Center / tai nghe.
- Duyệt theo cây thư mục và tìm kiếm bằng gõ chữ.
- Lặp lại, chọn bài phát tiếp theo, tua lùi / tới 5 giây.
- Dán link YouTube để phát trực tiếp hoặc tải audio về thư viện.
- Giao diện tối; mở app vào thẳng cây thư mục; có thanh phát thu nhỏ hiện bài nghe gần nhất.

**Không làm trong phạm vi này (non-goals)**
- Playlist, phát ngẫu nhiên, hẹn giờ tắt, chỉnh tốc độ, equalizer.
- Đồng bộ đám mây, nhiều người dùng, đăng nhập.
- Phát hành App Store, Android, Windows (các nền tảng khác chỉ dùng để chạy thử khi code).

**Tuyệt đối tránh (anti-goals)**
- **Không tự phát nhạc khi tai nghe kết nối.** App chỉ phát khi người dùng bấm.
- Không tự phát khi mở app: bài nghe gần nhất được nạp lên thanh mini ở trạng thái **tạm dừng**, đúng vị trí cũ.

## 3. Ràng buộc

| Ràng buộc | Hệ quả cho thiết kế |
|---|---|
| Code trên Windows, mượn Mac để build iOS | Máy Windows hiện **chưa cài Visual Studio** nên không build được Windows desktop, nhưng đã có Android emulator chạy sẵn. Quyết định của tôi: **giai đoạn 0–5 chạy thử trên Android emulator** (và điện thoại Android nếu có). Android chạy được `audio_service` thật (phát nền, thông báo, nút tai nghe) nên kiểm trước được phần lớn logic phát trước ngày mượn Mac. Việc chỉ kiểm được trên iOS gom vào giai đoạn 6. Code Swift chỉ compile được trên Mac. |
| Tài khoản Apple miễn phí: app hết hạn sau 7 ngày | Khuyến nghị tài khoản Apple Developer trả phí (99 USD/năm, chữ ký 1 năm). Nếu dùng miễn phí phải mượn Mac cài lại mỗi 7 ngày. |
| File mp3 chỉ có tên file, không tag | Hiển thị theo tên file; cho sửa tên / ca sĩ / ảnh bìa trong app. |
| YouTube không có API chính thức cho việc này | Dùng thư viện trích luồng (`youtube_explode_dart`). Có thể hỏng khi YouTube đổi cơ chế, cần `flutter pub upgrade` định kỳ. Dùng cá nhân nên không có rủi ro App Store. |
| iOS giới hạn truy cập thư mục ngoài sandbox | Cần security-scoped bookmark, Flutter chưa có plugin phổ biến làm việc này cho iOS, nên viết một platform channel Swift nhỏ (mục 6.2). |

## 4. Trải nghiệm người dùng

### 4.1 Lần đầu mở app
1. Màn hình trống với nút lớn **"Chọn thư mục nhạc"**.
2. Hệ thống mở trình chọn thư mục của iOS (Files). Người dùng chọn thư mục.
3. App lưu bookmark, quét thư mục (kể cả thư mục con), hiện cây thư mục.

### 4.2 Các lần mở sau
- Vào thẳng màn hình **Thư viện** (cây thư mục). App quét lại tất cả thư mục đã lưu ở nền; bài mới xuất hiện, bài bị xóa biến mất. Có kéo-để-làm-mới.
- Thanh **mini player** dưới cùng hiện bài nghe gần nhất (ảnh bìa, tên, nút play/pause), ở trạng thái tạm dừng. Bấm vào thanh mở màn hình phát.

### 4.3 Cấu trúc màn hình

```
Thư viện (gốc)                       <- mở app vào đây
├── [ô tìm kiếm] ------------> Kết quả tìm kiếm (danh sách bài)
├── Thư mục A  (đã chọn)
│   ├── Thư mục con A1 ------> Danh sách bài trong A1
│   └── bài1.mp3, bài2.mp3 ...
├── Thư mục B  (đã chọn)
├── YouTube  (thư mục đặc biệt do app quản lý, mục 4.6)
└── [+ Thêm thư mục]  [Cài đặt]

Mini player (cố định dưới cùng mọi màn hình) --> Màn hình phát
                                                   └── Hàng đợi
```

### 4.4 Danh sách bài trong thư mục
- Sắp theo tên (A đến Z, hiểu tiếng Việt có dấu).
- Mỗi dòng: ảnh bìa (mặc định icon nốt nhạc), tên hiển thị, ca sĩ (nếu có), thời lượng.
- Bấm vào bài: **hàng đợi = các bài nằm trực tiếp trong thư mục đó** (không gộp thư mục con), theo đúng thứ tự đang hiển thị, bắt đầu từ bài bấm. (Quyết định của tôi: hàng đợi luôn bằng danh sách người dùng đang nhìn thấy.)
- Giữ lâu / nút ⋯ mở menu: **Phát tiếp theo**, **Sửa thông tin**, **Xóa file** (có xác nhận).

### 4.5 Màn hình phát
- Ảnh bìa lớn, tên bài, ca sĩ, tên thư mục.
- Thanh tiến trình kéo được, thời gian đã phát / tổng.
- Hàng nút: `-5s`  `prev`  `play/pause`  `next`  `+5s`.
- Nút **Lặp lại** 3 trạng thái: tắt -> lặp cả hàng đợi -> lặp một bài.
- Nút **Hàng đợi** mở danh sách bài sắp phát, bài đang phát được đánh dấu, có thể kéo sắp xếp lại và xóa bài khỏi hàng đợi.
- Khi hết hàng đợi và không lặp: dừng, giữ bài cuối trên mini player.

### 4.6 YouTube
- Mục **YouTube** trong Thư viện mở màn hình có ô dán link + nút **Dán từ clipboard**.
- Sau khi dán: hiện tên video, ảnh thumbnail, thời lượng, hai nút **Phát ngay** và **Tải về**.
- **Phát ngay**: stream audio qua mạng, có đầy đủ điều khiển như bài thường (phát nền, màn hình khóa). Hàng đợi chỉ gồm bài đó.
- **Tải về**: tải luồng audio chất lượng cao nhất về thư mục `YouTube/` trong vùng Documents của app, kèm thumbnail làm ảnh bìa và tên video làm tên hiển thị. Hiện tiến trình tải, cho hủy. Sau khi xong, bài xuất hiện trong thư mục **YouTube** như bài offline bình thường.
- Lưu lịch sử link đã dán (tên, link, đã tải hay chưa) để phát lại nhanh.

### 4.7 Sửa thông tin bài
- Form: Tên hiển thị, Ca sĩ, Ảnh bìa (chọn từ thư viện ảnh). Chỉ lưu trong cơ sở dữ liệu của app, **không ghi vào file mp3**.
- Khi quét lần đầu, nếu tên file có dạng `Ca sĩ - Tên bài.mp3` thì app tách sẵn hai trường; không thì tên hiển thị = tên file bỏ phần mở rộng.

### 4.8 Cài đặt
- Danh sách thư mục đã chọn, nút xóa khỏi thư viện (không xóa file).
- Nút "Quét lại toàn bộ".
- Thông tin phiên bản, ghi chú nhắc chạy `flutter pub upgrade youtube_explode_dart` khi YouTube không phát được.

### 4.9 Màn hình khóa / Control Center / tai nghe
- Hiện ảnh bìa, tên bài, ca sĩ, thanh tiến trình kéo được.
- Nút: bài trước, play/pause, bài sau. (Quyết định của tôi: ±5 giây chỉ có trong app, vì nút tai nghe chỉ có prev/next và màn hình khóa iOS chỉ hiện tối đa 3 nút chính.)
- Nút tai nghe: bấm 1 = play/pause, bấm 2 = bài sau, bấm 3 = bài trước (iOS xử lý, app chỉ nhận lệnh).
- Rút tai nghe: tạm dừng. Cắm tai nghe: **không làm gì**.

## 5. Kiến trúc kỹ thuật (quyết định của tôi)

### 5.1 Thư viện

| Việc | Thư viện | Lý do |
|---|---|---|
| Phát audio | `just_audio` | Chuẩn de-facto Flutter, phát file local và URL stream, có seek, playlist. |
| Phát nền, màn hình khóa, tai nghe | `audio_service` | Quản lý MPNowPlayingInfoCenter và remote commands trên iOS; tách logic phát khỏi UI. |
| Phát audio trên Windows desktop (tùy chọn) | `just_audio_media_kit` | Chỉ cần nếu sau này cài Visual Studio và muốn chạy Windows desktop; không bắt buộc vì dev chính trên Android. |
| Phiên audio iOS | `audio_session` | Đặt category `playback`, xử lý rút tai nghe (`becomingNoisy` -> pause). |
| State management | `flutter_riverpod` (không codegen) | Nhẹ, test được, phù hợp stream từ audio_service. |
| Điều hướng | `go_router` | Mini player cố định qua `ShellRoute`. |
| Cơ sở dữ liệu | `drift` (SQLite) | Lưu thư mục, bài hát, metadata sửa tay, lịch sử YouTube, trạng thái phát. Truy vấn tìm kiếm nhanh. |
| Đọc thời lượng mp3 | `audio_metadata_reader` | Pure Dart, chạy trên mọi nền tảng, không cần nạp vào player để biết thời lượng. |
| Chọn thư mục trên Android / desktop (dev) | `file_picker` | `getDirectoryPath`. Trên Android cần thêm quyền `READ_MEDIA_AUDIO` (API 33+) hoặc `READ_EXTERNAL_STORAGE`. Trên iOS dùng channel riêng (6.2). |
| Chọn ảnh bìa | `image_picker` | |
| YouTube | `youtube_explode_dart` | Lấy thông tin video và URL luồng audio-only. |
| Tải file | `dio` | Có tiến trình tải và hủy. |
| Chuẩn hóa tiếng Việt khi tìm | `diacritic` | Gõ "nhac buon" tìm được "Nhạc Buồn". |
| Lưu cài đặt nhỏ | `shared_preferences` | Chế độ lặp, cờ đã onboarding. |

### 5.2 Cấu trúc thư mục `lib/`

```
lib/
  main.dart                 – khởi tạo audio_service, drift, ProviderScope
  app.dart                  – MaterialApp.router, theme tối
  core/
    db/                     – drift database, tables, DAO
    audio/
      audio_handler.dart    – MyAudioHandler extends BaseAudioHandler (just_audio bên trong)
      audio_session_config.dart
    folder_access/
      folder_access.dart    – interface: pickFolder(), restore(bookmark), listFiles()
      folder_access_ios.dart      – gọi MethodChannel 'my_music/folder'
      folder_access_desktop.dart  – file_picker + dart:io
    utils/ (normalize_vi.dart, filename_parser.dart)
  features/
    library/    – quét thư mục, cây thư mục, danh sách bài
    player/     – màn hình phát, mini player, hàng đợi, repeat
    search/
    youtube/    – resolve link, stream, download
    metadata/   – form sửa thông tin
    settings/
```

Nguyên tắc: UI chỉ nói chuyện với provider; provider gọi repository; repository gọi drift / folder_access / audio_handler. `MyAudioHandler` là nơi **duy nhất** điều khiển `just_audio`.

### 5.3 Mô hình dữ liệu (drift)

- `folders(id, bookmark BLOB, display_name, path_hint, added_at)` – bookmark là dữ liệu security-scoped (iOS) hoặc đường dẫn tuyệt đối (desktop).
- `tracks(id, folder_id, relative_path, file_name, title, artist, duration_ms, cover_path, search_text, source ENUM{local, youtube}, youtube_id?, last_seen_at)`. Khóa định danh = `(folder_id, relative_path)`; file bị đổi tên coi như bài mới, metadata sửa tay sẽ mất (chấp nhận).
- `youtube_history(id, video_id, title, thumbnail_url, duration_ms, downloaded_track_id?, added_at)`.
- `player_state(current_item JSON, position_ms, queue JSON, repeat_mode)` – một dòng duy nhất, ghi mỗi 5 giây khi đang phát và khi tạm dừng. `current_item` và các phần tử trong `queue` là **snapshot MediaItem** (`track_id?`, `youtube_id?`, title, artist, cover_path, duration) thay vì chỉ `track_id`, để bài YouTube phát trực tiếp (không có dòng `tracks`) vẫn hiện được trên mini player sau khi mở lại app. Khi bấm play một snapshot YouTube, app resolve lại URL luồng; nếu không có mạng thì báo lỗi và giữ trạng thái tạm dừng.

### 5.4 Quét thư mục
- Chạy khi mở app và khi kéo-làm-mới. Duyệt đệ quy, lọc `.mp3` và `.m4a`.
- So khớp với `tracks` theo `(folder_id, relative_path)`: thêm mới / cập nhật `last_seen_at` / xóa dòng không còn thấy.
- Đọc thời lượng bằng `audio_metadata_reader` chỉ cho bài mới (chạy trong `Isolate` để không giật UI).
- Trên iOS, mỗi lần quét phải `startAccessingSecurityScopedResource` -> đọc -> `stop`.

### 5.5 Hàng đợi & lặp
- Hàng đợi là `ConcatenatingAudioSource` của just_audio, phản chiếu trong `queue` của audio_service.
- "Phát tiếp theo" = chèn vào vị trí `currentIndex + 1`.
- Repeat: `LoopMode.off / all / one` của just_audio.
- ±5 giây = `seek(position ± 5s)` kẹp trong `[0, duration]`.

### 5.6 YouTube
- Nhận link dạng `youtube.com/watch?v=`, `youtu.be/`, `music.youtube.com`, `shorts/`. Trích `videoId`.
- `StreamManifest.audioOnly` -> chọn luồng container **mp4 (AAC)** bitrate cao nhất. Không chọn webm/opus vì iOS không phát được.
- Phát trực tiếp: `AudioSource.uri(streamUrl)` với `MediaItem` từ thông tin video. URL luồng hết hạn sau khoảng 6 giờ nên chỉ resolve ngay trước khi phát.
- Tải về: lưu thành `.m4a` trong `Documents/YouTube/` (quyết định của tôi: **không chuyển sang mp3** để tránh phụ thuộc ffmpeg; `.m4a` phát y hệt). Tên file = tên video đã làm sạch ký tự. Thêm vào `tracks` với `source = youtube`, `cover_path` = thumbnail đã tải.
- Thư mục `Documents/` của app được bật `UIFileSharingEnabled` + `LSSupportsOpeningDocumentsInPlace` nên cũng hiện trong ứng dụng Files dưới tên "My Music", người dùng có thể lấy file ra.

### 5.7 Tìm kiếm
- Chuẩn hóa cả truy vấn và `title`/`artist`/`file_name` bằng `diacritic.removeDiacritics` + lowercase, lưu vào cột `search_text` khi quét để truy vấn `LIKE %q%` trong drift.
- Kết quả hiển thị kèm tên thư mục. Bấm vào bài trong kết quả: hàng đợi = danh sách kết quả.

## 6. Cấu hình iOS (chỉ làm được trên Mac)

### 6.1 `ios/Runner/Info.plist`
- `UIBackgroundModes` = `[audio]`.
- `UIFileSharingEnabled` = true, `LSSupportsOpeningDocumentsInPlace` = true.
- `NSPhotoLibraryUsageDescription` (chọn ảnh bìa).
- Deployment target iOS 15 trở lên (`ios/Podfile`, Xcode project).

### 6.2 Platform channel chọn thư mục (`ios/Runner/FolderPicker.swift`, khoảng 80–100 dòng)
Channel `my_music/folder`, các method:
- `pickFolder()` -> mở `UIDocumentPickerViewController(forOpeningContentTypes: [.folder])`, trả `{ bookmark: Data(base64), path: String, name: String }` sau khi `url.bookmarkData()`.
- `resolve(bookmark)` -> `URL(resolvingBookmarkData:)`, nếu `isStale` thì tạo bookmark mới và trả về để lưu lại; gọi `startAccessingSecurityScopedResource`; trả path.
- `release(path)` -> `stopAccessingSecurityScopedResource`.
Phía Dart: `FolderAccessIos` gói các lệnh này, phía desktop trả thẳng đường dẫn.

### 6.3 `audio_service` trên iOS
- Không cần sửa `AppDelegate`; `AudioService.init` trong `main()` trước `runApp`.
- `AudioSessionConfiguration.music()`.
- Lắng nghe `becomingNoisyEventStream` -> `pause()`. **Không** đăng ký hành vi gì cho sự kiện kết nối tai nghe (anti-goal).

### 6.4 Ký và cài
- Xcode -> Runner -> Signing & Capabilities -> chọn Team. Đổi `PRODUCT_BUNDLE_IDENTIFIER` thành ID riêng (ví dụ `com.<tên bạn>.mymusic`), không giữ `com.example`.
- Chạy `flutter run --release -d <iPhone>` hoặc `flutter build ipa` rồi cài qua Xcode.
- Tài khoản miễn phí: 7 ngày; trả phí: 1 năm.

## 7. Plan triển khai theo giai đoạn

Mỗi giai đoạn kết thúc bằng `flutter analyze` sạch và `flutter test` xanh. Giai đoạn 0–5 code trên Windows, chạy thử trên Android emulator; giai đoạn 6 cần Mac.

### Giai đoạn 0 – Nền móng (0.5 ngày)
- Thêm dependencies ở 5.1, chạy `dart run build_runner build` cho drift.
- Xóa code counter, tạo cây thư mục `lib/` theo 5.2, theme tối, `go_router` với `ShellRoute` chứa mini player rỗng.
- Cập nhật `CLAUDE.md` với lệnh build_runner và kiến trúc.
- Kiểm: app chạy trên Android emulator, hiện màn hình Thư viện trống.

### Giai đoạn 1 – Thư viện offline (1.5 ngày)
- Drift: bảng `folders`, `tracks`, DAO.
- `FolderAccess` interface + `FolderAccessDefault` (Android / desktop, dùng `file_picker` + `dart:io`); `FolderAccessIos` chỉ là stub ném `UnimplementedError` (hoàn thiện ở giai đoạn 6).
- Dịch vụ quét (5.4) + `filename_parser` (tách `Ca sĩ - Tên bài`).
- UI: onboarding chọn thư mục, cây thư mục, danh sách bài, kéo-làm-mới, thêm / xóa thư mục trong Cài đặt.
- Test: unit `filename_parser`, unit quét với thư mục giả (thêm / xóa / giữ file), widget cây thư mục.

### Giai đoạn 2 – Phát nhạc (2 ngày)
- `MyAudioHandler` (just_audio + audio_service): play/pause/skip/seek, `rewind`/`fastForward` 5 giây, repeat, hàng đợi, "phát tiếp theo".
- `player_state`: lưu / khôi phục bài và vị trí gần nhất, nạp ở trạng thái tạm dừng khi mở app.
- UI: mini player, màn hình phát, màn hình hàng đợi (kéo sắp xếp, xóa).
- Chạy thử trên Android emulator: cấu hình `audio_service` cho Android (foreground service + notification channel trong `AndroidManifest.xml`), nhờ đó kiểm được phát nền, thông báo media và nút tai nghe trước ngày mượn Mac.
- Test: unit logic hàng đợi (chèn phát tiếp theo, kẹp seek ±5s), widget mini player.

### Giai đoạn 3 – Tìm kiếm (0.5 ngày)
- Cột `search_text`, `normalize_vi`, màn hình kết quả, hàng đợi từ kết quả.
- Test: unit `normalize_vi` ("Nhạc Buồn" <-> "nhac buon"), truy vấn drift.

### Giai đoạn 4 – Sửa thông tin bài (0.5 ngày)
- Form sửa tên / ca sĩ / ảnh bìa, lưu ảnh vào `ApplicationSupport/covers/<track_id>.jpg`.
- Xóa file có xác nhận.

### Giai đoạn 5 – YouTube (1.5 ngày)
- Trích `videoId`, resolve bằng `youtube_explode_dart`, màn hình dán link.
- Phát trực tiếp qua `MyAudioHandler`.
- Tải về bằng `dio` với tiến trình và hủy, ghi vào `Documents/YouTube/`, thêm vào `tracks`, tải thumbnail.
- Bảng `youtube_history` và danh sách lịch sử.
- Test: unit trích `videoId` từ các dạng link; chọn luồng mp4 bitrate cao nhất từ manifest giả.

### Giai đoạn 6 – Ngày mượn Mac (1 ngày, làm liền một đợt)
Chuẩn bị trước trên Windows: viết sẵn `FolderPicker.swift` và `FolderAccessIos` (chưa compile được), checklist dưới đây.
1. `flutter doctor`, cài CocoaPods, `pod install`.
2. Đổi bundle ID, chọn Team, bật Automatic signing.
3. Sửa `Info.plist` theo 6.1, deployment target.
4. Thêm `FolderPicker.swift` vào target Runner, đăng ký channel trong `AppDelegate.swift`.
5. `flutter run -d <iPhone>` debug, kiểm từng mục:
   - Chọn thư mục trong Files -> quét ra bài -> tắt app mở lại vẫn thấy (bookmark hoạt động).
   - Phát -> tắt màn hình -> nhạc không ngắt sau 1, 5, 30 phút.
   - Màn hình khóa / Control Center hiện ảnh bìa, tên, prev / play / next, kéo tiến trình.
   - AirPods: bấm 1/2/3 lần; rút tai nghe -> pause; cắm lại -> **không** phát.
   - Dán link YouTube -> phát nền OK; tải về -> hiện trong Files app.
   - Thư mục "My Music" hiện trong Files app.
6. `flutter run --release` để cài bản chính thức.
7. Ghi lại mọi lỗi iOS-only vào `docs/ios-issues.md` để sửa trên Windows nếu không kịp.

### Giai đoạn 7 – Hoàn thiện (tùy thời gian)
- Dynamic Island: iOS tự hiện Now Playing từ audio_service, không cần code thêm; chỉ kiểm.
- Hiệu năng quét với hơn 1000 file.
- Xử lý link YouTube lỗi (video riêng tư, bị chặn vùng) với thông báo rõ.

Tổng ước lượng: khoảng 8 ngày công, chưa tính chờ mượn Mac.

## 8. Để người triển khai tự quyết
- Màu nhấn của theme tối, font chữ, icon app.
- Cách hiển thị thời lượng khi chưa quét xong (ẩn hay "--:--").
- Số lần thử lại khi tải YouTube thất bại.
- Có dùng `freezed` cho model hay không.

## 9. Các quyết định tôi đã tự chốt (để bạn kiểm tra khi đọc)
1. Tải YouTube lưu `.m4a`, không chuyển mp3 (tránh ffmpeg).
2. ±5 giây chỉ trong app; màn hình khóa dùng prev / play / next.
3. Bấm một bài trong thư mục thì hàng đợi = cả thư mục đó; bấm từ kết quả tìm kiếm thì hàng đợi = kết quả.
4. Metadata sửa tay lưu trong DB, không ghi vào file; đổi tên file sẽ mất metadata.
5. Mở app nạp bài gần nhất ở trạng thái tạm dừng, không tự phát.
6. Chọn thư mục iOS qua platform channel Swift tự viết thay vì plugin bên thứ ba.
7. Quét file `.mp3` và `.m4a`.
8. Riverpod + go_router + drift làm bộ khung.
9. Giai đoạn 0–5 chạy thử trên Android emulator (máy Windows chưa có Visual Studio nên không build được Windows desktop; Android lại kiểm được audio_service thật).
10. Hàng đợi = danh sách đang hiển thị (bài trực tiếp trong thư mục, không gộp thư mục con).
11. `player_state` lưu snapshot MediaItem để bài YouTube phát trực tiếp vẫn hiện trên mini player khi mở lại; bấm play sẽ resolve lại URL.
