package model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/** Một dòng của đơn hàng: sản phẩm ở một size + tùy chọn + topping. */
public class ChiTietDonHang implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private SanPhamKichCo sanPhamKichCo;
    private int soLuong;
    private String mucDuong;
    private String mucDa;
    private long donGia;
    private long thanhTien;
    private List<ChiTietTopping> dsTopping = new ArrayList<>();

    public ChiTietDonHang() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public SanPhamKichCo getSanPhamKichCo() {
        return sanPhamKichCo;
    }

    public void setSanPhamKichCo(SanPhamKichCo sanPhamKichCo) {
        this.sanPhamKichCo = sanPhamKichCo;
    }

    public int getSoLuong() {
        return soLuong;
    }

    public void setSoLuong(int soLuong) {
        this.soLuong = soLuong;
    }

    public String getMucDuong() {
        return mucDuong;
    }

    public void setMucDuong(String mucDuong) {
        this.mucDuong = mucDuong;
    }

    public String getMucDa() {
        return mucDa;
    }

    public void setMucDa(String mucDa) {
        this.mucDa = mucDa;
    }

    public long getDonGia() {
        return donGia;
    }

    public void setDonGia(long donGia) {
        this.donGia = donGia;
    }

    public long getThanhTien() {
        return thanhTien;
    }

    public void setThanhTien(long thanhTien) {
        this.thanhTien = thanhTien;
    }

    public List<ChiTietTopping> getDsTopping() {
        return dsTopping;
    }

    public void setDsTopping(List<ChiTietTopping> dsTopping) {
        this.dsTopping = dsTopping;
    }

    /** soLuong × (giá size + Σ giá topping × số lượng topping). */
    public long tinhThanhTien() {
        long tp = 0;
        for (ChiTietTopping t : dsTopping) tp += t.getDonGia() * t.getSoLuong();
        return soLuong * (donGia + tp);
    }

    public String getMoTaTopping() {
        StringBuilder sb = new StringBuilder();
        for (ChiTietTopping t : dsTopping) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(t.getTopping().getTen());
            if (t.getSoLuong() > 1) sb.append(" x").append(t.getSoLuong());
        }
        return sb.toString();
    }
}
