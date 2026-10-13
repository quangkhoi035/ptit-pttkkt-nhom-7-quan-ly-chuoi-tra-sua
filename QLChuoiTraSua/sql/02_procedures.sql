-- =====================================================================
-- Stored procedure (Phần IV.II của báo cáo)
-- Chạy bằng MySQL client / MySQL Workbench / phpMyAdmin (tab SQL)
-- =====================================================================
USE qlchuoitrasua;

DROP PROCEDURE IF EXISTS sp_DangNhap;
DROP PROCEDURE IF EXISTS sp_LayMenuChiNhanh;
DROP PROCEDURE IF EXISTS sp_LayDSTopping;
DROP PROCEDURE IF EXISTS sp_TimThanhVien;
DROP PROCEDURE IF EXISTS sp_ThemThanhVien;
DROP PROCEDURE IF EXISTS sp_KiemTraKhuyenMai;
DROP PROCEDURE IF EXISTS sp_TaoDonHang;
DROP PROCEDURE IF EXISTS sp_ThemChiTietDon;
DROP PROCEDURE IF EXISTS sp_ThemChiTietTopping;
DROP PROCEDURE IF EXISTS sp_TruLuotKhuyenMai;
DROP PROCEDURE IF EXISTS sp_CongDiem;
DROP PROCEDURE IF EXISTS sp_ThongKeChiNhanh;
DROP PROCEDURE IF EXISTS sp_DSDonHangChiNhanh;
DROP PROCEDURE IF EXISTS sp_ChiTietDonHang;
DROP PROCEDURE IF EXISTS sp_DSDonPhaChe;
DROP PROCEDURE IF EXISTS sp_CapNhatTrangThaiDon;

DELIMITER $$

-- ===================== Đăng nhập =====================
-- Kiểm tra tên đăng nhập + mật khẩu (đã băm SHA-256 ở tầng Java)
CREATE PROCEDURE sp_DangNhap(IN p_tenDangNhap VARCHAR(50), IN p_matKhau VARCHAR(255))
BEGIN
  SELECT nv.id, nv.maNV, nv.chucVu, nd.id AS idNguoiDung, nd.hoTen, nd.sdt, nd.email,
         nd.ngaySinh, nd.tenDangNhap,
         cn.id AS idChiNhanh, cn.ma AS maCN, cn.ten AS tenCN, cn.diaChi AS diaChiCN
  FROM tblNguoiDung nd
  JOIN tblNhanVien nv      ON nv.idNguoiDung = nd.id
  LEFT JOIN tblChiNhanh cn ON cn.id = nv.idChiNhanh
  WHERE nd.tenDangNhap = p_tenDangNhap AND nd.matKhau = p_matKhau;
END$$

-- ===================== Module Bán hàng tại quầy =====================
-- Lấy thực đơn của một chi nhánh (kèm giá từng size).
-- Trả về cả món đang tắt bán (dangBan = 0) để giao diện hiển thị mờ + nhãn "Hết hàng"
-- theo ngoại lệ 3.1 của kịch bản.
CREATE PROCEDURE sp_LayMenuChiNhanh(IN p_maCN VARCHAR(10))
BEGIN
  SELECT sp.id, sp.ten, sp.moTa, sp.hinhAnh, dm.id AS idDanhMuc, dm.ten AS danhMuc,
         sc.dangBan, kc.id AS idKichCo, kc.ma AS size, kc.ten AS tenSize,
         spkc.id AS idSPKC, spkc.gia
  FROM tblSanPham sp
  JOIN tblDanhMuc dm         ON dm.id = sp.idDanhMuc
  JOIN tblChiNhanh cn        ON cn.ma = p_maCN
  JOIN tblSanPhamChiNhanh sc ON sc.idSanPham = sp.id AND sc.idChiNhanh = cn.id
  JOIN tblSanPhamKichCo spkc ON spkc.idSanPham = sp.id
  JOIN tblKichCo kc          ON kc.id = spkc.idKichCo
  WHERE sp.trangThai = 1
  ORDER BY dm.id, sp.id, kc.id;
END$$

CREATE PROCEDURE sp_LayDSTopping()
BEGIN
  SELECT id, ten, gia FROM tblTopping WHERE trangThai = 1 ORDER BY id;
END$$

-- Tìm thành viên theo SĐT
CREATE PROCEDURE sp_TimThanhVien(IN p_sdt VARCHAR(15))
BEGIN
  SELECT id, hoTen, sdt, ngaySinh, diemTichLuy, ngayDangKy FROM tblThanhVien WHERE sdt = p_sdt;
END$$

-- Đăng ký nhanh thành viên
CREATE PROCEDURE sp_ThemThanhVien(IN p_hoTen VARCHAR(100), IN p_sdt VARCHAR(15), OUT p_id INT)
BEGIN
  IF EXISTS (SELECT 1 FROM tblThanhVien WHERE sdt = p_sdt) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'So dien thoai da duoc dang ky';
  END IF;
  INSERT INTO tblThanhVien(hoTen, sdt, diemTichLuy, ngayDangKy) VALUES (p_hoTen, p_sdt, 0, NOW());
  SET p_id = LAST_INSERT_ID();
END$$

-- Kiểm tra mã khuyến mãi còn hiệu lực (còn hạn, còn lượt)
CREATE PROCEDURE sp_KiemTraKhuyenMai(IN p_maCode VARCHAR(20))
BEGIN
  SELECT id, maCode, tenKM, loaiGiam, giaTriGiam, giamToiDa, donToiThieu,
         ngayBatDau, ngayKetThuc, soLuotConLai
  FROM tblKhuyenMai
  WHERE maCode = p_maCode AND NOW() BETWEEN ngayBatDau AND ngayKetThuc AND soLuotConLai > 0;
END$$

-- Tạo đơn hàng; trả về id đơn
CREATE PROCEDURE sp_TaoDonHang(IN p_idCN INT, IN p_idNV INT, IN p_idTV INT, IN p_idKM INT,
    IN p_tong BIGINT, IN p_giam BIGINT, IN p_thanhTien BIGINT,
    IN p_ptTT VARCHAR(20), IN p_tienKhach BIGINT, OUT p_id INT)
BEGIN
  INSERT INTO tblDonHang(thoiGianTao, tongTien, giamGia, thanhTien, phuongThucTT, tienKhachDua,
                         trangThai, idChiNhanh, idNhanVien, idThanhVien, idKhuyenMai)
  VALUES (NOW(), p_tong, p_giam, p_thanhTien, p_ptTT, p_tienKhach, 'ChoPhaChe',
          p_idCN, p_idNV, p_idTV, p_idKM);
  SET p_id = LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_ThemChiTietDon(IN p_idDH INT, IN p_idSPKC INT, IN p_sl INT,
    IN p_duong VARCHAR(5), IN p_da VARCHAR(10), IN p_donGia BIGINT,
    IN p_thanhTien BIGINT, OUT p_id INT)
BEGIN
  INSERT INTO tblChiTietDonHang(soLuong, mucDuong, mucDa, donGia, thanhTien, idDonHang, idSanPhamKichCo)
  VALUES (p_sl, p_duong, p_da, p_donGia, p_thanhTien, p_idDH, p_idSPKC);
  SET p_id = LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_ThemChiTietTopping(IN p_idCT INT, IN p_idTP INT, IN p_sl INT, IN p_donGia BIGINT)
BEGIN
  INSERT INTO tblChiTietTopping(soLuong, donGia, idChiTietDonHang, idTopping)
  VALUES (p_sl, p_donGia, p_idCT, p_idTP);
END$$

CREATE PROCEDURE sp_TruLuotKhuyenMai(IN p_idKM INT)
BEGIN
  UPDATE tblKhuyenMai SET soLuotConLai = soLuotConLai - 1
  WHERE id = p_idKM AND soLuotConLai > 0 AND NOW() BETWEEN ngayBatDau AND ngayKetThuc;
  IF ROW_COUNT() = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ma khuyen mai da het luot hoac het han';
  END IF;
END$$

CREATE PROCEDURE sp_CongDiem(IN p_idTV INT, IN p_thanhTien BIGINT)
BEGIN
  UPDATE tblThanhVien SET diemTichLuy = diemTichLuy + FLOOR(p_thanhTien / 10000) WHERE id = p_idTV;
END$$

-- ===================== Module Thống kê doanh thu theo chi nhánh =====================
-- Chỉ tính đơn Hoàn thành, tính trọn ngày kết thúc
CREATE PROCEDURE sp_ThongKeChiNhanh(IN p_tuNgay DATE, IN p_denNgay DATE)
BEGIN
  SELECT cn.id, cn.ma, cn.ten, cn.diaChi,
         COUNT(dh.id)                 AS soDon,
         IFNULL(SUM(dh.thanhTien), 0) AS doanhThu
  FROM tblChiNhanh cn
  LEFT JOIN tblDonHang dh
         ON dh.idChiNhanh = cn.id
        AND dh.trangThai = 'HoanThanh'
        AND dh.thoiGianTao >= p_tuNgay
        AND dh.thoiGianTao <  DATE_ADD(p_denNgay, INTERVAL 1 DAY)
  GROUP BY cn.id, cn.ma, cn.ten, cn.diaChi
  ORDER BY doanhThu DESC, cn.ma;
END$$

-- Danh sách đơn hoàn thành của một chi nhánh
CREATE PROCEDURE sp_DSDonHangChiNhanh(IN p_idCN INT, IN p_tuNgay DATE, IN p_denNgay DATE)
BEGIN
  SELECT dh.id, dh.thoiGianTao, dh.tongTien, dh.giamGia, dh.thanhTien, dh.phuongThucTT,
         nd.hoTen AS thuNgan, tv.hoTen AS khachHang
  FROM tblDonHang dh
  JOIN tblNhanVien nv       ON nv.id = dh.idNhanVien
  JOIN tblNguoiDung nd      ON nd.id = nv.idNguoiDung
  LEFT JOIN tblThanhVien tv ON tv.id = dh.idThanhVien
  WHERE dh.idChiNhanh = p_idCN AND dh.trangThai = 'HoanThanh'
    AND dh.thoiGianTao >= p_tuNgay
    AND dh.thoiGianTao <  DATE_ADD(p_denNgay, INTERVAL 1 DAY)
  ORDER BY dh.thoiGianTao DESC;
END$$

-- Chi tiết một đơn: result set 1 = thông tin đơn, 2 = các món, 3 = topping
CREATE PROCEDURE sp_ChiTietDonHang(IN p_idDH INT)
BEGIN
  SELECT dh.id, dh.thoiGianTao, dh.tongTien, dh.giamGia, dh.thanhTien, dh.phuongThucTT,
         dh.tienKhachDua, dh.trangThai,
         cn.id AS idChiNhanh, cn.ma AS maCN, cn.ten AS tenCN,
         nd.hoTen AS thuNgan, tv.id AS idThanhVien, tv.hoTen AS khachHang, tv.sdt AS sdtKhach,
         km.id AS idKhuyenMai, km.maCode
  FROM tblDonHang dh
  JOIN tblChiNhanh cn        ON cn.id = dh.idChiNhanh
  JOIN tblNhanVien nv        ON nv.id = dh.idNhanVien
  JOIN tblNguoiDung nd       ON nd.id = nv.idNguoiDung
  LEFT JOIN tblThanhVien tv  ON tv.id = dh.idThanhVien
  LEFT JOIN tblKhuyenMai km  ON km.id = dh.idKhuyenMai
  WHERE dh.id = p_idDH;

  SELECT ct.id, sp.ten, kc.ma AS size, ct.mucDuong, ct.mucDa, ct.soLuong, ct.donGia, ct.thanhTien
  FROM tblChiTietDonHang ct
  JOIN tblSanPhamKichCo spkc ON spkc.id = ct.idSanPhamKichCo
  JOIN tblSanPham sp         ON sp.id = spkc.idSanPham
  JOIN tblKichCo kc          ON kc.id = spkc.idKichCo
  WHERE ct.idDonHang = p_idDH
  ORDER BY ct.id;

  SELECT ctt.idChiTietDonHang, tp.id AS idTopping, tp.ten, ctt.soLuong, ctt.donGia
  FROM tblChiTietTopping ctt
  JOIN tblTopping tp         ON tp.id = ctt.idTopping
  JOIN tblChiTietDonHang ct  ON ct.id = ctt.idChiTietDonHang
  WHERE ct.idDonHang = p_idDH
  ORDER BY ctt.id;
END$$

-- ===================== Pha chế (UC "Cập nhật trạng thái pha chế") =====================
CREATE PROCEDURE sp_DSDonPhaChe(IN p_idCN INT)
BEGIN
  SELECT dh.id, dh.thoiGianTao, dh.trangThai, dh.thanhTien, nd.hoTen AS thuNgan
  FROM tblDonHang dh
  JOIN tblNhanVien nv  ON nv.id = dh.idNhanVien
  JOIN tblNguoiDung nd ON nd.id = nv.idNguoiDung
  WHERE dh.idChiNhanh = p_idCN AND dh.trangThai IN ('ChoPhaChe','DangPhaChe')
  ORDER BY dh.thoiGianTao;
END$$

-- Chuyển trạng thái đúng thứ tự: ChoPhaChe -> DangPhaChe -> HoanThanh
CREATE PROCEDURE sp_CapNhatTrangThaiDon(IN p_idDH INT, IN p_idCN INT,
                                        IN p_tu VARCHAR(20), IN p_den VARCHAR(20))
BEGIN
  UPDATE tblDonHang SET trangThai = p_den
  WHERE id = p_idDH AND idChiNhanh = p_idCN AND trangThai = p_tu;
  SELECT ROW_COUNT() AS soDong;
END$$

DELIMITER ;
