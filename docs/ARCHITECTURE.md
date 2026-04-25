# Tài liệu Kiến trúc — Advanced Calculator

## 1. Mô hình tổng thể: MVVM với Provider

**Quyết định:** Sử dụng gói Provider với một lớp `CalculatorProvider` đóng vai trò ViewModel duy nhất.

**Lý do:**
- Yêu cầu từ đề cương môn học.
- `ChangeNotifier` kết hợp với `Consumer` đủ đáp ứng nhu cầu phản ứng của ứng dụng mà không cần BLoC hay Riverpod.
- Một provider duy nhất giữ toàn bộ state machine trong một chỗ, giúp dễ đọc và dễ kiểm thử.

---

## 2. Mô hình State Machine lấy biểu thức làm trung tâm

**Quyết định:** Biến `_expr` (chuỗi biểu thức thô) là **nguồn sự thật duy nhất**. Biến `_display` chỉ là bản sao đọc của `_expr`.

**Vấn đề của thiết kế cũ:**

Thiết kế ban đầu phân tách trạng thái thành `_expr` (các token đã xác nhận) và `_display` (số đang nhập). Cách này gây ra lỗi ghi đè khi người dùng nhấn các hàm như `sin(` hoặc hằng số như π — màn hình bị đặt lại, làm mất các token đã nhập trước đó.

**Thiết kế mới:**

Mỗi lần nhấn phím đều append trực tiếp vào `_expr`:

```
Nhấn: sin  -->  _expr += "sin("
Nhấn: 4    -->  _expr += "4"
Nhấn: 5    -->  _expr += "5"
Nhấn: )    -->  _expr += ")"   (nếu có ngoặc mở tương ứng)
```

`_display = _expr.isEmpty ? '0' : _expr` — luôn đồng bộ, không có khả năng phân kỳ.

---

## 3. Lớp tính toán thuần túy: CalculatorLogic

**Quyết định:** Toàn bộ logic tính toán nằm trong một lớp static `CalculatorLogic`, không phụ thuộc vào Flutter.

| Phương thức | Trách nhiệm |
|-------------|------------|
| `evaluate(expr, {angleMode})` | Điểm vào — tiền xử lý, phân tích, trả kết quả |
| `_preprocess(expr, mode)` | Làm sạch Unicode, chuẩn hóa toán tử, nhân ngầm định |
| `_tokenize(expr)` | Chuyển chuỗi thành danh sách token, hỗ trợ ký hiệu khoa học |
| `_parse(expr, mode)` | Bộ phân tích đệ quy; fnMap xử lý deg/rad trực tiếp |
| `formatResult(value, {precision})` | Định dạng double sang chuỗi hiển thị |

**Lý do:** Hàm thuần túy có thể kiểm thử không cần mock. Chế độ góc được tiêm vào khi khởi tạo fnMap, không qua regex trên chuỗi thô, tránh lỗi ghi đè hàm lượng giác ngược.

---

## 4. Bộ phân tích đệ quy giảm dần (Recursive-Descent Parser)

**Ngữ pháp (từ độ ưu tiên thấp đến cao):**

```
expr     -> addSub
addSub   -> mulDiv  (('+' | '-') mulDiv)*
mulDiv   -> unary   (('×' | '÷') unary)*
unary    -> '-' power | power
power    -> primary ('^' unary)?      -- kết hợp phải
primary  -> '(' expr ')' | fn '(' expr ')' | số | hằng số
```

**Các quyết định chính:**

- `unary` gọi `power` (không phải `primary`) nên `-2^2 = -(2^2) = -4`, đúng với quy ước toán học chuẩn.
- `power` kết hợp phải: `2^3^2 = 2^(3^2) = 512`.
- Dấu `!` (giai thừa) được xử lý bằng vòng lặp `while` trong `primary` để hỗ trợ giai thừa kép `3!! = 720`.

---

## 5. Xử lý chế độ góc trong fnMap (không dùng Regex)

**Quyết định:** Chuyển đổi Độ – Radian được thực hiện bên trong lambda của `fnMap`, không xử lý trên chuỗi biểu thức thô.

**Vấn đề của phương pháp regex:**

```dart
// Sai: biến asin(0.5) thành (0.5*(180/π)) — xóa luôn tên hàm!
RegExp('$fn\\(([^)]+)\\)').replaceAllMapped(...)
```

Ngoài ra, `[^)]+` không xử lý được ngoặc lồng như `sin((30+60))`.

**Phương pháp đúng:**

```dart
'sin':  (x) => math.sin(isDeg ? x * math.pi / 180 : x),
'asin': (x) => isDeg ? math.asin(x) * 180 / math.pi : math.asin(x),
```

---

## 6. Lưu trữ dữ liệu qua StorageService

**Quyết định:** Toàn bộ các truy vấn SharedPreferences được đóng gói sau giao diện `StorageService`.

**Lý do:**
- Tách rời provider khỏi implementation lưu trữ.
- Dễ dàng thay thế bằng đối tượng giả lập khi kiểm thử.
- Tập trung tên khóa — không có chuỗi ma thuật nào nằm rải rác trong code.

**Dữ liệu được lưu:**

| Khóa | Kiểu | Mặc định |
|------|------|---------|
| history | Danh sách JSON | [] |
| memory | double | 0.0 |
| calcMode | chỉ số int | 0 (Cơ bản) |
| angleMode | chỉ số int | 0 (Độ) |
| precision | int | 10 |
| haptic | bool | true |
| sound | bool | false |
| historySize | int | 50 |
| theme | chỉ số int | 2 (Hệ thống) |

---

## 7. Thông số thiết kế (theo đặc tả Figma)

| Thông số | Giá trị |
|----------|---------|
| Font | Roboto |
| Cỡ chữ phím | 16px (Regular) |
| Cỡ chữ màn hình chính | 32px (Medium) |
| Cỡ chữ lịch sử | 18px (Light) |
| Khoảng cách phím | 12px |
| Bo tròn góc phím | 16px |
| Bo tròn góc màn hình | 24px |
| Padding màn hình | 24px |
| Hoạt ảnh nhấn phím | 200ms scale |
| Hoạt ảnh chuyển chế độ | 300ms |
| Màu nhấn sáng | #FF6B6B |
| Màu nhấn tối | #4ECDC4 |

---

## 8. Quy tắc nhân ngầm định

Bộ tiền xử lý chèn ký hiệu nhân theo các trường hợp sau (theo thứ tự):

| Mẫu | Ví dụ | Kết quả |
|-----|-------|---------|
| Số liền kề dấu ngoặc mở | 3(2+1) | 3×(2+1) |
| Số liền kề chữ cái | 3sin | 3×sin |
| Ngoặc đóng trước ngoặc mở | (2)(3) | (2)×(3) |
| Ngoặc đóng trước chữ cái | )sin | )×sin |
| Nhấn phím hằng số sau giá trị | Nhấn π sau 2 | 2×π |

**Quy ước:** Nhân ngầm định có cùng độ ưu tiên với nhân tường minh (trái sang phải), phù hợp với Google Calculator và các máy tính khoa học hiện đại.
