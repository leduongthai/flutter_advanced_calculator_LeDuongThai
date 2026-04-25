# Tài liệu Kiểm thử — Advanced Calculator

## Cách chạy kiểm thử

```bash
# Chạy tất cả các bài kiểm thử
flutter test

# Chạy một file cụ thể
flutter test test/calculator_logic_test.dart

# Chạy với báo cáo độ phủ sóng
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html       # macOS
xdg-open coverage/html/index.html  # Linux
```

---

## Các file kiểm thử

| File | Phạm vi |
|------|---------|
| test/calculator_logic_test.dart | Kiểm thử đơn vị cho CalculatorLogic (bộ tính toán thuần túy) |
| test/calculator_provider_test.dart | Kiểm thử đơn vị cho CalculatorProvider (state machine) |

---

## calculator_logic_test.dart — Các nhóm kiểm thử

### Số học cơ bản

| Tên kiểm thử | Biểu thức | Kết quả mong đợi |
|-------------|-----------|-----------------|
| Phép cộng | 2+3 | 5 |
| Phép trừ | 10-4 | 6 |
| Phép nhân | 3×4 | 12 |
| Phép chia | 15÷3 | 5 |
| Số thập phân | 1.5+2.5 | 4.0 |
| Chia cho 0 | 5÷0 | Ném FormatException |

### Độ ưu tiên toán tử (PEMDAS)

| Tên kiểm thử | Biểu thức | Kết quả mong đợi |
|-------------|-----------|-----------------|
| Nhân trước cộng | 2+3×4 | 14 |
| Chia trước trừ | 10-6÷2 | 7 |
| Ngoặc ghi đè | (2+3)×4 | 20 |
| Biểu thức phức tạp | (5+3)×2-4÷2 | 14 (TC1) |
| Ngoặc lồng | ((2+3)×(4-1))÷5 | 3 (TC5) |
| Lũy thừa kết hợp phải | 2^3^2 | 512 |

### Hàm lượng giác — chế độ Độ

| Tên kiểm thử | Biểu thức | Kết quả mong đợi |
|-------------|-----------|-----------------|
| sin(45)+cos(45) | sin(45)+cos(45) | xấp xỉ 1.414 (TC2) |
| asin(1) | asin(1) | 90.0 độ |
| atan(1) | atan(1) | 45.0 độ |
| sin(0) | sin(0) | 0.0 |
| cos(90) | cos(90) | 0.0 |

### Hàm lượng giác — chế độ Radian

| Tên kiểm thử | Biểu thức | Kết quả mong đợi |
|-------------|-----------|-----------------|
| sin(π/2) | sin(1.5707...) | 1.0 |
| cos(π) | cos(3.1415...) | -1.0 |

### Logarit

| Tên kiểm thử | Biểu thức | Kết quả mong đợi |
|-------------|-----------|-----------------|
| ln(e) | ln(2.718...) | 1.0 |
| log(100) | log(100) | 2.0 |
| Lỗi miền ln | ln(0) | Ném ngoại lệ |
| Lỗi miền log | log(-1) | Ném ngoại lệ |

### Lũy thừa và căn

| Tên kiểm thử | Biểu thức | Kết quả mong đợi |
|-------------|-----------|-----------------|
| 2^10 | 2^10 | 1024 |
| sqrt(9) | sqrt(9) | 3.0 |
| cbrt(27) | cbrt(27) | 3.0 |
| cbrt(-8) (Sửa lỗi B) | cbrt(-8) | -2.0 |
| sqrt số âm | sqrt(-1) | Ném ngoại lệ |

### Khoa học tổng hợp

| Tên kiểm thử | Biểu thức | Kết quả mong đợi |
|-------------|-----------|-----------------|
| 2×π×sqrt(9) | 2×π×sqrt(9) | xấp xỉ 18.85 (TC6) |
| sin²+cos²=1 | sin(30)^2+cos(30)^2 | 1.0 |

### Các hàm trợ giúp cho chế độ Lập trình

| Tên kiểm thử | Đầu vào | Kết quả mong đợi |
|-------------|---------|-----------------|
| toBinary(10) | — | "1010" |
| toHex(255) | — | "FF" |
| AND 0xFF & 0x0F | — | 0x0F (TC7) |
| OR 0xF0 OR 0x0F | — | 0xFF |
| XOR 0xFF XOR 0x0F | — | 0xF0 |
| Dịch trái 1 << 3 | — | 8 |
| Dịch phải 8 >> 2 | — | 2 |

### Định dạng kết quả (formatResult)

| Tên kiểm thử | Đầu vào | Kết quả mong đợi |
|-------------|---------|-----------------|
| Số nguyên | 42.0 | "42" |
| Cắt số 0 thừa | 3.1400 | "3.14" |
| NaN | double.nan | "Error" |
| Vô cực | double.infinity | "∞" |
| Số rất nhỏ | 0.000000001 | Chứa "e" |
| Số rất lớn | 1e16 | Chứa "e" |

### Xử lý lỗi và trường hợp biên

| Tên kiểm thử | Đầu vào | Kết quả mong đợi |
|-------------|---------|-----------------|
| Biểu thức rỗng | "" | Ném ngoại lệ |
| Token lạ | "foo+1" | Ném ngoại lệ |
| Thiếu ngoặc đóng | "(2+3" | Ném ngoại lệ |

---

## Các kịch bản kiểm thử của đề cương (Step 8)

Tất cả 7 kịch bản yêu cầu đều được xác nhận đạt:

| Số thứ tự | Kịch bản | Kết quả |
|-----------|---------|---------|
| TC1 | (5+3)×2-4÷2 | 14 — đạt |
| TC2 | sin(45)+cos(45) | xấp xỉ 1.414 — đạt |
| TC3 | Bộ nhớ: 5 M+, 3 M+, MR | 8 — đạt |
| TC4 | Dây chuyền: 5+3=, +2=, +1= | 11 — đạt |
| TC5 | ((2+3)×(4-1))÷5 | 3 — đạt |
| TC6 | 2×π×sqrt(9) | xấp xỉ 18.85 — đạt |
| TC7 | 0xFF AND 0x0F | 0x0F — đạt |

---

## Kiểm thử hồi quy cho lỗi nhập liệu (calculator_provider_test.dart)

| Kịch bản | Dãy phím | Kết quả `_expr` mong đợi |
|---------|---------|------------------------|
| Hàm sau số | 3 + sin( 4 5 ) | 3+sin(45) |
| Ngoặc đóng | ( 2 + 3 ) | (2+3) |
| Hai hàm liên tiếp | sin(30)+cos(60) | sin(30)+cos(60) |
| Hằng số sau số | 2 × π × 3 | 2×π×3 |
| DEL xóa đúng | sin(45 rồi DEL | sin(4 |
| Sau =, chữ số bắt đầu mới | 5+3= rồi nhấn 4 | 4 (không phải 84) |
| Sau =, toán tử tiếp tục | 5+3= rồi +2= | 10 |

---

## Bảng xác nhận các sửa lỗi

| Sửa lỗi | Mô tả | Kiểm thử tương ứng |
|---------|-------|-------------------|
| Sửa 1A | asin bị regex ghi đè | test asin(1) == 90 |
| Sửa 1B | Ngoặc lồng trong hàm lượng giác | test sin((30+60)) |
| Sửa 2A | (2+3)! bị bỏ qua | Kịch bản provider |
| Sửa 2B | 5.5! cho kết quả sai thầm lặng | Kiểm thử ném ngoại lệ |
| Sửa 3 | 1.2e-4 bị tokenize sai | test ký hiệu khoa học |
| Sửa 4 | -2^2 = 4 sai | test độ ưu tiên dấu âm |
| Sửa 5 | 3sin(90) không có toán tử | test nhân ngầm định |
| Sửa A | 3!! token thứ hai gây lỗi | test giai thừa kép |
| Sửa B | cbrt(-8) trả về NaN | test cbrt âm |
| Sửa D | Ngưỡng số nguyên 1e15 sai trên web | test giới hạn JS |
| Sửa E | Ký tự Unicode vô hình phá tokenizer | test làm sạch Unicode |

---

## Mục tiêu độ phủ sóng

Mục tiêu: trên 80% đối với `lib/utils/calculator_logic.dart`.

Bộ kiểm thử bao gồm:
- Tất cả các toán tử số học
- Tất cả 14 hàm tích hợp sẵn
- Cả hai chế độ góc (Độ và Radian)
- Tokenize ký hiệu khoa học
- Tất cả đường lối lỗi (lỗi miền, chia cho 0, giai thừa không hợp lệ)
- Các trường hợp biên của formatResult
- Tất cả hàm trợ giúp cho chế độ Lập trình
