# Flutter Advanced Calculator

Ứng dụng máy tính khoa học tiên tiến xây dựng bằng Flutter, hỗ trợ ba chế độ tính toán, phân tích biểu thức với độ ưu tiên toán tử đầy đủ, lịch sử tính toán, chuyển đổi giao diện sáng/tối và kiểm thử đơn vị toàn diện.

---

## Tính năng chính

### Ba chế độ máy tính

| Chế độ | Mô tả |
|--------|-------|
| Cơ bản | Lưới phím 4x5, các phép tính số học thông thường |
| Khoa học | Lưới phím 6x6, lượng giác, logarit, lũy thừa, giai thừa, bộ nhớ |
| Lập trình | Chuyển đổi nhị phân / bát phân / thập phân / thập lục phân, các phép toán bit |

### Chức năng cốt lõi

- **Trình phân tích biểu thức**: Độ ưu tiên toán tử PEMDAS/BODMAS, dấu ngoặc, nhân ngầm định (2π = 2×π)
- **Hàm khoa học**: sin, cos, tan, asin, acos, atan (DEG/RAD), ln, log, log₂, √, ∛, x², x³, xʸ, n!
- **Hàm bộ nhớ**: M+, M−, MR, MC
- **Hằng số**: π, e
- **Phép toán lập trình**: AND, OR, XOR, NOT, dịch bit trái/phải

### Giao diện người dùng

- Giao diện sáng và tối với chuyển đổi mượt mà
- Màn hình nhiều dòng: biểu thức hiện tại và kết quả trước đó
- Lịch sử tính toán có thể cuộn (50 mục gần nhất), chạm để tái sử dụng
- Chỉ báo DEG/RAD và trạng thái bộ nhớ
- Hiệu ứng hoạt ảnh nhấn phím (200ms), chuyển chế độ (300ms)
- Hiệu ứng rung khi có lỗi

### Cài đặt

- Giao diện: Sáng / Tối / Hệ thống
- Độ chính xác thập phân: 2–10 chữ số
- Chế độ góc: Độ / Radian
- Phản hồi xúc giác: Bật/Tắt
- Hiệu ứng âm thanh: Bật/Tắt
- Kích thước lịch sử: 25 / 50 / 100 mục
- Xóa toàn bộ lịch sử (có hộp thoại xác nhận)

### Lưu trữ dữ liệu

Tất cả cài đặt và lịch sử được lưu qua SharedPreferences và phục hồi khi khởi động lại ứng dụng.

---

## Ảnh chụp màn hình

Đặt ảnh chụp màn hình vào thư mục `screenshots/`.

| Chế độ Cơ bản | Chế độ Khoa học | Chế độ Lập trình |
|:---:|:---:|:---:|
| screenshots/basic_light.png | screenshots/scientific_dark.png | screenshots/programmer.png |

| Bảng lịch sử | Màn hình Cài đặt |
|:---:|:---:|
| screenshots/history.png | screenshots/settings.png |

---

## Kiến trúc dự án

```
lib/
├── main.dart
├── models/
│   ├── calculation_history.dart
│   ├── calculator_mode.dart
│   └── calculator_settings.dart
├── providers/
│   ├── calculator_provider.dart
│   └── theme_provider.dart
├── screens/
│   ├── calculator_screen.dart
│   ├── history_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── display_area.dart
│   ├── button_grid.dart
│   ├── calculator_button.dart
│   └── mode_selector.dart
├── utils/
│   ├── calculator_logic.dart
│   └── constants.dart
└── services/
    └── storage_service.dart
```

Xem `docs/ARCHITECTURE.md` để biết thêm chi tiết về các quyết định kiến trúc.

---

## Hướng dẫn cài đặt

### Yêu cầu tiên quyết

- Flutter SDK >= 3.0 (Dart >= 2.17)
- Android Studio hoặc VS Code với plugin Flutter
- Thiết bị kết nối hoặc máy ảo

### Các bước thực hiện

```bash
# 1. Clone repository
git clone https://github.com/<ten-nguoi-dung>/flutter_advanced_calculator_<ten>.git
cd flutter_advanced_calculator_<ten>

# 2. Cài đặt các gói phụ thuộc
flutter pub get

# 3. Chạy ứng dụng
flutter run

# 4. Build APK bản phát hành (tùy chọn)
flutter build apk --release
```

---

## Hướng dẫn kiểm thử

```bash
# Chạy tất cả các bài kiểm thử
flutter test

# Chạy với báo cáo độ phủ sóng
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

Độ phủ sóng mục tiêu: trên 80% đối với `calculator_logic.dart`.

Xem `docs/TESTING.md` để biết tài liệu kiểm thử đầy đủ.

---

## Hạn chế đã biết

- Trong chế độ Lập trình, toán tử XOR sử dụng ký hiệu `^` trùng với lũy thừa ở chế độ Khoa học. Hai chế độ được giữ riêng biệt nên không xảy ra xung đột, nhưng chuyển chế độ sẽ đặt lại biểu thức.
- Giai thừa lớn (n > 170) vượt quá giới hạn double và trả về Infinity, đây là hạn chế của IEEE 754.
- Không hỗ trợ vẽ đồ thị và nhập liệu bằng giọng nói (tính năng tùy chọn bonus).
- Giao diện tối ưu cho chế độ dọc; chế độ ngang có thể scale nhưng chưa có layout riêng.

---

## Định hướng phát triển

- Layout riêng cho chế độ ngang và tablet
- Vẽ đồ thị hàm số y = f(x) sử dụng fl_chart
- Nhập liệu bằng giọng nói với speech_to_text
- Xuất lịch sử sang CSV hoặc PDF
- Công cụ tạo giao diện màu tùy chọn
- Hỗ trợ số phức và ma trận

---

## Gói phụ thuộc

| Gói | Phiên bản | Mục đích |
|-----|-----------|---------|
| provider | ^6.1.1 | Quản lý trạng thái |
| shared_preferences | ^2.2.2 | Lưu trữ dữ liệu |
| math_expressions | ^2.4.0 | Tham khảo biểu thức |
| intl | ^0.18.1 | Định dạng số |
| mockito | ^5.4.4 | Mô phỏng trong kiểm thử |

---

## Liêm chính học thuật

Bài nộp này là sản phẩm của cá nhân người học. Các tài nguyên bên ngoài (tài liệu Flutter, pub.dev) chỉ được tham khảo để sử dụng API, không sao chép trực tiếp.
