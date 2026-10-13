package model;

import java.io.Serializable;

/** Một topping kèm theo một dòng chi tiết đơn. */
public class ChiTietTopping implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private Topping topping;
    private int soLuong;
    private long donGia;

    public ChiTietTopping() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Topping getTopping() {
        return topping;
    }

    public void setTopping(Topping topping) {
        this.topping = topping;
    }

    public int getSoLuong() {
        return soLuong;
    }

    public void setSoLuong(int soLuong) {
        this.soLuong = soLuong;
    }

    public long getDonGia() {
        return donGia;
    }

    public void setDonGia(long donGia) {
        this.donGia = donGia;
    }
}
