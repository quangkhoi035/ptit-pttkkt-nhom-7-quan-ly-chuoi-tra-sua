package model;

import java.io.Serializable;

/** Topping thêm vào ly. */
public class Topping implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private String ten;
    private long gia;
    private boolean trangThai;

    public Topping() {
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

    public long getGia() {
        return gia;
    }

    public void setGia(long gia) {
        this.gia = gia;
    }

    public boolean isTrangThai() {
        return trangThai;
    }

    public void setTrangThai(boolean trangThai) {
        this.trangThai = trangThai;
    }
}
