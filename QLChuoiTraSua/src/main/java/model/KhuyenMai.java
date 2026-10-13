package model;

import java.io.Serializable;
import java.util.Date;

/** Mã khuyến mãi. loaiGiam ∈ {PhanTram, SoTien}. */
public class KhuyenMai implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private String maCode;
    private String tenKM;
    private String loaiGiam;
    private long giaTriGiam;
    private Long giamToiDa;
    private long donToiThieu;
    private Date ngayBatDau;
    private Date ngayKetThuc;
    private int soLuotConLai;

    public KhuyenMai() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getMaCode() {
        return maCode;
    }

    public void setMaCode(String maCode) {
        this.maCode = maCode;
    }

    public String getTenKM() {
        return tenKM;
    }

    public void setTenKM(String tenKM) {
        this.tenKM = tenKM;
    }

    public String getLoaiGiam() {
        return loaiGiam;
    }

    public void setLoaiGiam(String loaiGiam) {
        this.loaiGiam = loaiGiam;
    }

    public long getGiaTriGiam() {
        return giaTriGiam;
    }

    public void setGiaTriGiam(long giaTriGiam) {
        this.giaTriGiam = giaTriGiam;
    }

    public Long getGiamToiDa() {
        return giamToiDa;
    }

    public void setGiamToiDa(Long giamToiDa) {
        this.giamToiDa = giamToiDa;
    }

    public long getDonToiThieu() {
        return donToiThieu;
    }

    public void setDonToiThieu(long donToiThieu) {
        this.donToiThieu = donToiThieu;
    }

    public Date getNgayBatDau() {
        return ngayBatDau;
    }

    public void setNgayBatDau(Date ngayBatDau) {
        this.ngayBatDau = ngayBatDau;
    }

    public Date getNgayKetThuc() {
        return ngayKetThuc;
    }

    public void setNgayKetThuc(Date ngayKetThuc) {
        this.ngayKetThuc = ngayKetThuc;
    }

    public int getSoLuotConLai() {
        return soLuotConLai;
    }

    public void setSoLuotConLai(int soLuotConLai) {
        this.soLuotConLai = soLuotConLai;
    }

    /** Công thức ở Phần IV.III.3 của báo cáo. */
    public long tinhTienGiam(long tongTien) {
        if (tongTien < donToiThieu) return 0;
        if ("PhanTram".equals(loaiGiam)) {
            long giam = tongTien * giaTriGiam / 100;
            return giamToiDa == null ? giam : Math.min(giam, giamToiDa);
        }
        return Math.min(giaTriGiam, tongTien);
    }
}
