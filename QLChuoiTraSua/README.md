# QLChuoiTraSua – Hệ thống quản lý chuỗi cửa hàng trà sữa

Ứng dụng Java Web (JSP + JDBC + MySQL), cài đặt theo báo cáo PTTK HTTT của nhóm 7. Có đủ hai module trọng tâm:

- **Bán hàng tại quầy** (thu ngân): chọn món, size, đường, đá, topping; tìm hoặc đăng ký nhanh thành viên; áp mã khuyến mãi; thanh toán; in hóa đơn.
- **Thống kê doanh thu theo chi nhánh** (quản lý chuỗi): thống kê theo khoảng ngày; xem danh sách đơn của chi nhánh; xem chi tiết đơn.

Ngoài ra có thêm màn hình **pha chế** để chuyển đơn sang "Hoàn thành". Chỉ đơn Hoàn thành mới được tính vào doanh thu.

## 1. Yêu cầu

| Thành phần | Phiên bản |
| --- | --- |
| JDK | 8 trở lên |
| Apache Tomcat | 9.x (dùng `javax.servlet`, không dùng Tomcat 10) |
| MySQL | 8.x (MariaDB 10.5+ cũng chạy được) |
| IDE | NetBeans 8.2 trở lên (hoặc IntelliJ, Eclipse); project dạng Maven |

## 2. Tạo cơ sở dữ liệu

Chạy lần lượt 3 file trong thư mục `sql/` bằng MySQL Workbench (File → Open SQL Script → Execute) hoặc dòng lệnh:

```bash
mysql -u root -p < sql/01_schema.sql       # tạo CSDL qlchuoitrasua + các bảng
mysql -u root -p < sql/02_procedures.sql   # các stored procedure
mysql -u root -p < sql/03_data.sql         # dữ liệu mẫu (~2.300 đơn từ 01/09 đến 12/10/2026)
```

Chạy lại `01_schema.sql` sẽ xóa và tạo lại toàn bộ CSDL.

## 3. Cấu hình kết nối

Mở `src/main/resources/db.properties` và sửa `db.user`, `db.password` cho đúng MySQL trên máy:

```properties
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://localhost:3306/qlchuoitrasua?useUnicode=true&characterEncoding=UTF-8&allowPublicKeyRetrieval=true&useSSL=false
db.user=root
db.password=
```

## 4. Chạy ứng dụng

**NetBeans:**
1. File → Open Project → chọn thư mục `QLChuoiTraSua`. NetBeans tự nhận đây là project Maven.
2. Nếu chưa có Tomcat 9: Tools → Servers → Add Server → Apache Tomcat → trỏ tới thư mục cài Tomcat 9.
3. Chuột phải project → Properties → Run → Server: chọn Tomcat 9.
4. Chuột phải project → Run. Lần đầu NetBeans tải thư viện Maven, nên máy cần có Internet.

**Dòng lệnh:** chạy `mvn package`, rồi chép `target/QLChuoiTraSua.war` vào thư mục `webapps/` của Tomcat.

Mở trình duyệt tại: <http://localhost:8080/QLChuoiTraSua>

## 5. Tài khoản mẫu (mật khẩu đều là `123456`)

| Tài khoản | Họ tên | Chức vụ | Chi nhánh |
| --- | --- | --- | --- |
| `thungan01` | Nguyễn Thị Lan | Thu ngân | CN01 Cầu Giấy |
| `thungan02` | Lê Quốc Huy | Thu ngân | CN01 Cầu Giấy |
| `thungan03` … `thungan05` | | Thu ngân | CN02 … CN04 |
| `phache01`, `phache02` | | Pha chế | CN01, CN02 |
| `quanly` | Phạm Đức Anh | Quản lý chuỗi | – |
| `qlch01` | Trịnh Thu Hà | Quản lý cửa hàng | Ngoài phạm vi: hệ thống từ chối đăng nhập kèm thông báo |

Dữ liệu dùng để demo:

| Loại | Dữ liệu |
| --- | --- |
| Thành viên | Trần Văn Minh – `0912345678` – 125 điểm |
| Khuyến mãi còn hiệu lực | `GIAM20K` (−20.000đ, đơn từ 100.000đ, hạn 31/12/2026); `GIAM10P` (−10%, tối đa 15.000đ, đơn từ 50.000đ) |
| Khuyến mãi không dùng được | `SALE10` (hết hạn 31/08/2026); `HETLUOT` (hết lượt) |
| Món tạm ngừng bán | Trà sữa khoai môn tại CN01 (hiển thị mờ, nhãn "HẾT HÀNG") |

## 6. Demo theo kịch bản trong báo cáo

**Bán hàng tại quầy:** đăng nhập `thungan01` và thực hiện:
1. Chọn **Tạo đơn mới**.
2. Thêm 2 × Trà sữa trân châu đường đen size L, 50% đường, ít đá, topping Kem cheese.
3. Thêm 1 × Trà đào cam sả size M, 70% đường, đá vừa.
4. Tìm SĐT `0912345678`.
5. Áp mã `GIAM20K`. Màn hình hiện Tổng 149.000, Giảm 20.000, Thành tiền 129.000.
6. Bấm **Thanh toán**, chọn Tiền mặt, nhập 200.000. Tiền thừa là 71.000. Bấm **Xác nhận**.
7. Hóa đơn hiện ra và khách Minh được cộng 12 điểm (lên 137).

**Pha chế:** đăng nhập `phache01`, bấm **Bắt đầu pha chế** rồi **Hoàn thành & giao món**.

**Thống kê:** đăng nhập `quanly` → Xem báo cáo → Doanh thu theo chi nhánh → chọn 01/09/2026 – 30/09/2026 → bấm một chi nhánh → bấm một đơn.

Các ngoại lệ đều đã cài và thử được, ví dụ:
- SĐT sai định dạng hoặc chưa có (khi đó hiện form đăng ký nhanh).
- Mã khuyến mãi hết hạn hoặc chưa đạt giá trị đơn tối thiểu.
- Tiền khách đưa không đủ.
- Ngày kết thúc nhỏ hơn ngày bắt đầu, bỏ trống ngày.
- Khoảng ngày không có dữ liệu.

## 7. Cấu trúc project (khớp Hình 3.17 – Biểu đồ gói)

```text
QLChuoiTraSua/
├── pom.xml
├── sql/                     01_schema.sql, 02_procedures.sql, 03_data.sql
├── tools/gen_data.py        script sinh dữ liệu mẫu (không cần khi chạy)
└── src/main/
    ├── java/
    │   ├── model/   NguoiDung, NhanVien, ChiNhanh, TKChiNhanh, ThanhVien, DanhMuc, KichCo,
    │   │            SanPham, SanPhamKichCo, Topping, KhuyenMai, DonHang, ChiTietDonHang, ChiTietTopping
    │   ├── dao/     DAO, NhanVienDAO, SanPhamDAO, ThanhVienDAO, KhuyenMaiDAO, DonHangDAO, TKChiNhanhDAO
    │   └── util/    Web (định dạng tiền/ngày, chống XSS, kiểm tra quyền), MatKhau (SHA-256)
    ├── resources/db.properties
    └── webapp/
        ├── GDDangNhap.jsp, doDangNhap.jsp, DangXuat.jsp, Header.jsp, Footer.jsp
        ├── thungan/      GDChinhThuNgan, GDTaoDon, doTaoDon, GDThanhToan, doThanhToan, GDHoaDon
        ├── quanlychuoi/  GDChinhQLC, GDChonTK, GDTKChiNhanh, GDDSDonHang, GDChiTietDon
        ├── phache/       GDPhaChe, doPhaChe
        └── css/style.css
```

Trang JSP gọi DAO; DAO gọi stored procedure. Đơn đang lập được giữ trong session. Khi thanh toán, `DonHangDAO.luuDonHang()` lưu mọi thứ trong **một giao tác**: đơn, chi tiết, topping, trừ lượt khuyến mãi, cộng điểm. Lỗi ở bất kỳ bước nào thì rollback toàn bộ.
