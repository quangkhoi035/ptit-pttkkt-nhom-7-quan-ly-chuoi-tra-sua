-- =====================================================================
-- CSDL hệ thống quản lý chuỗi cửa hàng trà sữa
-- Theo Phần III.II "Thiết kế cơ sở dữ liệu" của báo cáo PTTK
-- MySQL 8 (chạy được cả trên MariaDB 10.5+)
-- =====================================================================
DROP DATABASE IF EXISTS qlchuoitrasua;
CREATE DATABASE qlchuoitrasua CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE qlchuoitrasua;

-- ---------- Người dùng, nhân viên, chi nhánh ----------
CREATE TABLE tblChiNhanh (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  ma        VARCHAR(10)  NOT NULL UNIQUE,
  ten       VARCHAR(100) NOT NULL,
  diaChi    VARCHAR(255) NOT NULL,
  sdt       VARCHAR(15),
  hoatDong  BIT NOT NULL DEFAULT 1
);

CREATE TABLE tblNguoiDung (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  hoTen        VARCHAR(100) NOT NULL,
  sdt          VARCHAR(15),
  email        VARCHAR(100),
  ngaySinh     DATE,
  tenDangNhap  VARCHAR(50)  NOT NULL UNIQUE,
  matKhau      VARCHAR(255) NOT NULL          -- SHA-256 (hex)
);

CREATE TABLE tblNhanVien (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  maNV         VARCHAR(10) NOT NULL UNIQUE,
  chucVu       VARCHAR(20) NOT NULL,
  idNguoiDung  INT NOT NULL UNIQUE,
  idChiNhanh   INT NULL,                       -- NULL với quản lý chuỗi
  CONSTRAINT ck_nv_chucvu CHECK (chucVu IN ('ThuNgan','PhaChe','QuanLyCH','QuanLyChuoi')),
  CONSTRAINT fk_nv_nd FOREIGN KEY (idNguoiDung) REFERENCES tblNguoiDung(id),
  CONSTRAINT fk_nv_cn FOREIGN KEY (idChiNhanh)  REFERENCES tblChiNhanh(id)
);

-- ---------- Thành viên, khuyến mãi ----------
CREATE TABLE tblThanhVien (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  hoTen        VARCHAR(100) NOT NULL,
  sdt          VARCHAR(15)  NOT NULL UNIQUE,
  ngaySinh     DATE,
  diemTichLuy  INT NOT NULL DEFAULT 0,
  ngayDangKy   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT ck_tv_diem CHECK (diemTichLuy >= 0)
);

CREATE TABLE tblKhuyenMai (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  maCode        VARCHAR(20) NOT NULL UNIQUE,
  tenKM         VARCHAR(100),
  loaiGiam      VARCHAR(10) NOT NULL,
  giaTriGiam    BIGINT NOT NULL,
  giamToiDa     BIGINT NULL,
  donToiThieu   BIGINT NOT NULL DEFAULT 0,
  ngayBatDau    DATETIME NOT NULL,
  ngayKetThuc   DATETIME NOT NULL,
  soLuotConLai  INT NOT NULL DEFAULT 0,
  CONSTRAINT ck_km_loai CHECK (loaiGiam IN ('PhanTram','SoTien')),
  CONSTRAINT ck_km_luot CHECK (soLuotConLai >= 0)
);

-- ---------- Thực đơn ----------
CREATE TABLE tblDanhMuc (
  id   INT AUTO_INCREMENT PRIMARY KEY,
  ten  VARCHAR(50) NOT NULL
);

CREATE TABLE tblSanPham (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  ten        VARCHAR(100) NOT NULL,
  moTa       VARCHAR(500),
  hinhAnh    VARCHAR(255),
  trangThai  BIT NOT NULL DEFAULT 1,
  idDanhMuc  INT NOT NULL,
  CONSTRAINT fk_sp_dm FOREIGN KEY (idDanhMuc) REFERENCES tblDanhMuc(id)
);

CREATE TABLE tblKichCo (
  id   INT AUTO_INCREMENT PRIMARY KEY,
  ma   CHAR(1)     NOT NULL UNIQUE,
  ten  VARCHAR(20) NOT NULL
);

CREATE TABLE tblSanPhamKichCo (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  gia         BIGINT NOT NULL,
  idSanPham   INT NOT NULL,
  idKichCo    INT NOT NULL,
  CONSTRAINT uq_spkc UNIQUE (idSanPham, idKichCo),
  CONSTRAINT ck_spkc_gia CHECK (gia > 0),
  CONSTRAINT fk_spkc_sp FOREIGN KEY (idSanPham) REFERENCES tblSanPham(id),
  CONSTRAINT fk_spkc_kc FOREIGN KEY (idKichCo)  REFERENCES tblKichCo(id)
);

CREATE TABLE tblSanPhamChiNhanh (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  dangBan     BIT NOT NULL DEFAULT 1,
  idSanPham   INT NOT NULL,
  idChiNhanh  INT NOT NULL,
  CONSTRAINT uq_spcn UNIQUE (idSanPham, idChiNhanh),
  CONSTRAINT fk_spcn_sp FOREIGN KEY (idSanPham)  REFERENCES tblSanPham(id),
  CONSTRAINT fk_spcn_cn FOREIGN KEY (idChiNhanh) REFERENCES tblChiNhanh(id)
);

CREATE TABLE tblTopping (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  ten        VARCHAR(50) NOT NULL,
  gia        BIGINT NOT NULL,
  trangThai  BIT NOT NULL DEFAULT 1
);

-- ---------- Đơn hàng ----------
CREATE TABLE tblDonHang (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  thoiGianTao   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tongTien      BIGINT NOT NULL,
  giamGia       BIGINT NOT NULL DEFAULT 0,
  thanhTien     BIGINT NOT NULL,
  phuongThucTT  VARCHAR(20) NOT NULL,
  tienKhachDua  BIGINT NOT NULL,
  trangThai     VARCHAR(20) NOT NULL,
  idChiNhanh    INT NOT NULL,
  idNhanVien    INT NOT NULL,
  idThanhVien   INT NULL,
  idKhuyenMai   INT NULL,
  CONSTRAINT ck_dh_pttt CHECK (phuongThucTT IN ('TienMat','ChuyenKhoan')),
  CONSTRAINT ck_dh_tt   CHECK (trangThai IN ('ChoPhaChe','DangPhaChe','HoanThanh','DaHuy')),
  CONSTRAINT fk_dh_cn FOREIGN KEY (idChiNhanh)  REFERENCES tblChiNhanh(id),
  CONSTRAINT fk_dh_nv FOREIGN KEY (idNhanVien)  REFERENCES tblNhanVien(id),
  CONSTRAINT fk_dh_tv FOREIGN KEY (idThanhVien) REFERENCES tblThanhVien(id),
  CONSTRAINT fk_dh_km FOREIGN KEY (idKhuyenMai) REFERENCES tblKhuyenMai(id)
);
-- Chỉ mục phục vụ thống kê theo chi nhánh + khoảng ngày (Bước 5)
CREATE INDEX ix_dh_cn_tg ON tblDonHang (idChiNhanh, thoiGianTao);

CREATE TABLE tblChiTietDonHang (
  id                INT AUTO_INCREMENT PRIMARY KEY,
  soLuong           INT NOT NULL,
  mucDuong          VARCHAR(5)  NOT NULL,
  mucDa             VARCHAR(10) NOT NULL,
  donGia            BIGINT NOT NULL,          -- giá size tại thời điểm bán
  thanhTien         BIGINT NOT NULL,
  idDonHang         INT NOT NULL,
  idSanPhamKichCo   INT NOT NULL,
  CONSTRAINT ck_ctdh_sl CHECK (soLuong > 0),
  CONSTRAINT fk_ctdh_dh   FOREIGN KEY (idDonHang)       REFERENCES tblDonHang(id),
  CONSTRAINT fk_ctdh_spkc FOREIGN KEY (idSanPhamKichCo) REFERENCES tblSanPhamKichCo(id)
);

CREATE TABLE tblChiTietTopping (
  id                 INT AUTO_INCREMENT PRIMARY KEY,
  soLuong            INT NOT NULL,
  donGia             BIGINT NOT NULL,         -- giá topping tại thời điểm bán
  idChiTietDonHang   INT NOT NULL,
  idTopping          INT NOT NULL,
  CONSTRAINT fk_ctt_ct FOREIGN KEY (idChiTietDonHang) REFERENCES tblChiTietDonHang(id),
  CONSTRAINT fk_ctt_tp FOREIGN KEY (idTopping)        REFERENCES tblTopping(id)
);

-- ---------- Các bảng ngoài phạm vi 2 module (đủ theo sơ đồ CSDL) ----------
CREATE TABLE tblCaLam (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  ngay         DATE NOT NULL,
  gioBatDau    TIME NOT NULL,
  gioKetThuc   TIME NOT NULL,
  idNhanVien   INT NOT NULL,
  idChiNhanh   INT NOT NULL,
  CONSTRAINT fk_cl_nv FOREIGN KEY (idNhanVien) REFERENCES tblNhanVien(id),
  CONSTRAINT fk_cl_cn FOREIGN KEY (idChiNhanh) REFERENCES tblChiNhanh(id)
);

CREATE TABLE tblNguyenLieu (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  ten        VARCHAR(100) NOT NULL,
  donViTinh  VARCHAR(20)  NOT NULL
);

CREATE TABLE tblTonKho (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  soLuong       FLOAT NOT NULL DEFAULT 0,
  idChiNhanh    INT NOT NULL,
  idNguyenLieu  INT NOT NULL,
  CONSTRAINT uq_tk UNIQUE (idChiNhanh, idNguyenLieu),
  CONSTRAINT fk_tk_cn FOREIGN KEY (idChiNhanh)   REFERENCES tblChiNhanh(id),
  CONSTRAINT fk_tk_nl FOREIGN KEY (idNguyenLieu) REFERENCES tblNguyenLieu(id)
);

CREATE TABLE tblNhaCungCap (
  id      INT AUTO_INCREMENT PRIMARY KEY,
  ten     VARCHAR(255) NOT NULL,
  diaChi  VARCHAR(255),
  sdt     VARCHAR(15)
);

CREATE TABLE tblPhieuNhap (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  ngayNhap       DATETIME NOT NULL,
  tongTien       BIGINT NOT NULL,
  idNhaCungCap   INT NOT NULL,
  idChiNhanh     INT NOT NULL,
  CONSTRAINT fk_pn_ncc FOREIGN KEY (idNhaCungCap) REFERENCES tblNhaCungCap(id),
  CONSTRAINT fk_pn_cn  FOREIGN KEY (idChiNhanh)   REFERENCES tblChiNhanh(id)
);

CREATE TABLE tblChiTietPhieuNhap (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  soLuong        FLOAT  NOT NULL,
  donGia         BIGINT NOT NULL,
  idPhieuNhap    INT NOT NULL,
  idNguyenLieu   INT NOT NULL,
  CONSTRAINT fk_ctpn_pn FOREIGN KEY (idPhieuNhap)  REFERENCES tblPhieuNhap(id),
  CONSTRAINT fk_ctpn_nl FOREIGN KEY (idNguyenLieu) REFERENCES tblNguyenLieu(id)
);
