package model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/** Đơn hàng tại quầy. trangThai ∈ {ChoPhaChe, DangPhaChe, HoanThanh, DaHuy}. */
public class DonHang implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private Date thoiGianTao;
    private long tongTien;
    private long giamGia;
    private long thanhTien;
    private String phuongThucTT;
    private long tienKhachDua;
    private String trangThai;
    private ChiNhanh chiNhanh;
    private NhanVien thuNgan;
    private ThanhVien khachHang;
    private KhuyenMai khuyenMai;
    private List<ChiTietDonHang> dsChiTiet = new ArrayList<>();

    public DonHang() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Date getThoiGianTao() {
        return thoiGianTao;
    }

    public void setThoiGianTao(Date thoiGianTao) {
        this.thoiGianTao = thoiGianTao;
    }

    public long getTongTien() {
        return tongTien;
    }

    public void setTongTien(long tongTien) {
        this.tongTien = tongTien;
    }

    public long getGiamGia() {
        return giamGia;
    }

    public void setGiamGia(long giamGia) {
        this.giamGia = giamGia;
    }

    public long getThanhTien() {
        return thanhTien;
    }

    public void setThanhTien(long thanhTien) {
        this.thanhTien = thanhTien;
    }

    public String getPhuongThucTT() {
        return phuongThucTT;
    }

    public void setPhuongThucTT(String phuongThucTT) {
        this.phuongThucTT = phuongThucTT;
    }

    public long getTienKhachDua() {
        return tienKhachDua;
    }

    public void setTienKhachDua(long tienKhachDua) {
        this.tienKhachDua = tienKhachDua;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public ChiNhanh getChiNhanh() {
        return chiNhanh;
    }

    public void setChiNhanh(ChiNhanh chiNhanh) {
        this.chiNhanh = chiNhanh;
    }

    public NhanVien getThuNgan() {
        return thuNgan;
    }

    public void setThuNgan(NhanVien thuNgan) {
        this.thuNgan = thuNgan;
    }

    public ThanhVien getKhachHang() {
        return khachHang;
    }

    public void setKhachHang(ThanhVien khachHang) {
        this.khachHang = khachHang;
    }

    public KhuyenMai getKhuyenMai() {
        return khuyenMai;
    }

    public void setKhuyenMai(KhuyenMai khuyenMai) {
        this.khuyenMai = khuyenMai;
    }

    public List<ChiTietDonHang> getDsChiTiet() {
        return dsChiTiet;
    }

    public void setDsChiTiet(List<ChiTietDonHang> dsChiTiet) {
        this.dsChiTiet = dsChiTiet;
    }

    public long tinhTongTien() {
        long t = 0;
        for (ChiTietDonHang ct : dsChiTiet) t += ct.tinhThanhTien();
        return t;
    }

    /** Tính lại tổng tiền, tiền giảm và thành tiền sau mỗi lần thay đổi đơn. */
    public void capNhatTien() {
        for (ChiTietDonHang ct : dsChiTiet) ct.setThanhTien(ct.tinhThanhTien());
        tongTien = tinhTongTien();
        giamGia = khuyenMai == null ? 0 : khuyenMai.tinhTienGiam(tongTien);
        thanhTien = tongTien - giamGia;
    }

    /** Mã đơn hiển thị, ví dụ DH000521. */
    public String getMaDon() {
        return String.format("DH%06d", id);
    }

    public String getTenTrangThai() {
        if ("ChoPhaChe".equals(trangThai)) return "Chờ pha chế";
        if ("DangPhaChe".equals(trangThai)) return "Đang pha chế";
        if ("HoanThanh".equals(trangThai)) return "Hoàn thành";
        if ("DaHuy".equals(trangThai)) return "Đã hủy";
        return trangThai;
    }

    public String getTenPhuongThucTT() {
        return "ChuyenKhoan".equals(phuongThucTT) ? "Chuyển khoản" : "Tiền mặt";
    }
}
