package model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/** Sản phẩm trong thực đơn chung của chuỗi. */
public class SanPham implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private String ten;
    private String moTa;
    private String hinhAnh;
    private boolean trangThai;
    private DanhMuc danhMuc;
    private boolean dangBan;
    private List<SanPhamKichCo> dsGia = new ArrayList<>();

    public SanPham() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTen() {
        return ten;
    }

    public void setTen(String ten) {
        this.ten = ten;
    }

    public String getMoTa() {
        return moTa;
    }

    public void setMoTa(String moTa) {
        this.moTa = moTa;
    }

    public String getHinhAnh() {
        return hinhAnh;
    }

    public void setHinhAnh(String hinhAnh) {
        this.hinhAnh = hinhAnh;
    }

    public boolean isTrangThai() {
        return trangThai;
    }

    public void setTrangThai(boolean trangThai) {
        this.trangThai = trangThai;
    }

    public DanhMuc getDanhMuc() {
        return danhMuc;
    }

    public void setDanhMuc(DanhMuc danhMuc) {
        this.danhMuc = danhMuc;
    }

    public boolean isDangBan() {
        return dangBan;
    }

    public void setDangBan(boolean dangBan) {
        this.dangBan = dangBan;
    }

    public List<SanPhamKichCo> getDsGia() {
        return dsGia;
    }

    public void setDsGia(List<SanPhamKichCo> dsGia) {
        this.dsGia = dsGia;
    }

    /** Giá thấp nhất trong các size, để hiển thị "từ ...đ". */
    public long getGiaTu() {
        long min = Long.MAX_VALUE;
        for (SanPhamKichCo g : dsGia) min = Math.min(min, g.getGia());
        return dsGia.isEmpty() ? 0 : min;
    }
}
