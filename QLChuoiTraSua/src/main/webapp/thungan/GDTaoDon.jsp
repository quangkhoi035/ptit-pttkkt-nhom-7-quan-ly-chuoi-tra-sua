<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*, model.*, dao.SanPhamDAO, util.Web"%>
<%
    NhanVien nv = Web.yeuCau(request, response, NhanVien.THU_NGAN);
    if (nv == null) return;
    String tieuDe = "Tạo đơn";

    // Đơn đang lập lưu trong session (trạng thái "Đang lập" chỉ tồn tại trên giao diện)
    DonHang dh = (DonHang) session.getAttribute("donHang");
    if (dh == null) {
        dh = new DonHang();
        dh.setChiNhanh(nv.getChiNhanh());
        dh.setThuNgan(nv);
        session.setAttribute("donHang", dh);
    }
    // Thực đơn + topping: lấy một lần mỗi đơn mới để giá thống nhất trong suốt quá trình lập đơn
    @SuppressWarnings("unchecked")
    List<SanPham> menu = (List<SanPham>) session.getAttribute("menu");
    @SuppressWarnings("unchecked")
    List<Topping> dsTopping = (List<Topping>) session.getAttribute("dsTopping");
    if (menu == null || dh.getDsChiTiet().isEmpty()) {
        try (SanPhamDAO dao = new SanPhamDAO()) {
            menu = dao.getMenuChiNhanh(nv.getChiNhanh().getMa());
            dsTopping = dao.getDSTopping();
        }
        session.setAttribute("menu", menu);
        session.setAttribute("dsTopping", dsTopping);
    }
    Map<String, List<SanPham>> theoDM = new LinkedHashMap<>();
    for (SanPham sp : menu) {
        String dm = sp.getDanhMuc().getTen();
        if (!theoDM.containsKey(dm)) theoDM.put(dm, new ArrayList<SanPham>());
        theoDM.get(dm).add(sp);
    }
    String tvChuaCo = (String) session.getAttribute("tvChuaCo");
    String[] mucDuong = {"0", "30", "50", "70", "100"};
    String[] mucDa = {"Không đá", "Ít", "Vừa", "Nhiều"};
    String ctx = request.getContextPath();
%>
<%@include file="/Header.jsp"%>
<div class="pos">
    <div>
        <div class="tabs" id="tabs">
            <% int k = 0; for (String dm : theoDM.keySet()) { %>
            <button type="button" class="<%= k == 0 ? "on" : "" %>" data-tab="t<%= k %>"><%= Web.h(dm) %></button>
            <% k++; } %>
        </div>
        <% k = 0; for (Map.Entry<String, List<SanPham>> e : theoDM.entrySet()) { %>
        <div class="menu" id="t<%= k %>" <%= k == 0 ? "" : "hidden" %>>
            <% for (SanPham sp : e.getValue()) { %>
                <% if (sp.isDangBan()) { %>
                <button type="button" class="sp" data-dlg="d<%= sp.getId() %>">
                    <div class="img">🧋</div>
                    <b><%= Web.h(sp.getTen()) %></b>
                    <span class="gia">từ <%= Web.tien(sp.getGiaTu()) %></span>
                </button>
                <% } else { %>
                <div class="sp het" title="Món đang tạm ngừng bán tại chi nhánh">
                    <div class="img">🧋</div>
                    <b><%= Web.h(sp.getTen()) %></b>
                    <span class="gia">HẾT HÀNG</span>
                </div>
                <% } %>
            <% } %>
        </div>
        <% k++; } %>
    </div>

    <div class="card order">
        <h2>ĐƠN HÀNG</h2>
        <% if (dh.getDsChiTiet().isEmpty()) { %>
            <p class="muted">Chưa có món nào. Chọn món ở thực đơn bên trái.</p>
        <% } %>
        <% for (int i = 0; i < dh.getDsChiTiet().size(); i++) { ChiTietDonHang ct = dh.getDsChiTiet().get(i); %>
        <div class="line">
            <div class="info">
                <b><%= ct.getSoLuong() %> × <%= Web.h(ct.getSanPhamKichCo().getSanPham().getTen()) %> (<%= ct.getSanPhamKichCo().getKichCo().getMa() %>)</b>
                <small><%= ct.getMucDuong() %>% đường · <%= Web.h(ct.getMucDa()) %> đá<%= ct.getDsTopping().isEmpty() ? "" : " · + " + Web.h(ct.getMoTaTopping()) %></small>
            </div>
            <div class="tien"><%= Web.tien(ct.getThanhTien()) %></div>
            <form method="post" action="<%= ctx %>/thungan/doTaoDon.jsp">
                <input type="hidden" name="action" value="xoa"><input type="hidden" name="dong" value="<%= i %>">
                <button class="btn-link" title="Xóa dòng">✕</button>
            </form>
        </div>
        <% } %>

        <div class="box">
            <% if (dh.getKhachHang() != null) { %>
                <div class="row" style="justify-content:space-between">
                    <span class="tv"><%= Web.h(dh.getKhachHang().getHoTen()) %> – <%= dh.getKhachHang().getDiemTichLuy() %> điểm</span>
                    <form method="post" action="<%= ctx %>/thungan/doTaoDon.jsp">
                        <input type="hidden" name="action" value="boChonTV"><button class="btn-link">Bỏ thành viên</button>
                    </form>
                </div>
                <div class="muted"><%= Web.h(dh.getKhachHang().getSdt()) %></div>
            <% } else if (tvChuaCo != null) { %>
                <div class="alert alert-info">Không tìm thấy thành viên <b><%= Web.h(tvChuaCo) %></b>. Đăng ký nhanh?</div>
                <form method="post" action="<%= ctx %>/thungan/doTaoDon.jsp" class="row">
                    <input type="hidden" name="action" value="dangKyTV">
                    <input type="text" name="hoTen" placeholder="Họ tên khách" required maxlength="100">
                    <button class="btn">Đăng ký nhanh</button>
                </form>
                <form method="post" action="<%= ctx %>/thungan/doTaoDon.jsp" style="margin-top:6px">
                    <input type="hidden" name="action" value="boQuaTV"><button class="btn btn-ghost btn-sm">Bỏ qua</button>
                </form>
            <% } else { %>
                <form method="post" action="<%= ctx %>/thungan/doTaoDon.jsp" class="row">
                    <input type="hidden" name="action" value="timTV">
                    <label for="sdt">SĐT thành viên</label>
                    <input type="text" id="sdt" name="sdt" placeholder="0912345678" maxlength="15" inputmode="numeric">
                    <button class="btn btn-ghost">Tìm</button>
                </form>
            <% } %>
        </div>

        <div class="box">
            <% if (dh.getKhuyenMai() != null) { %>
                <div class="row" style="justify-content:space-between">
                    <span>Mã <b><%= Web.h(dh.getKhuyenMai().getMaCode()) %></b> – <%= Web.h(dh.getKhuyenMai().getTenKM()) %></span>
                    <form method="post" action="<%= ctx %>/thungan/doTaoDon.jsp">
                        <input type="hidden" name="action" value="boKM"><button class="btn-link">Bỏ mã</button>
                    </form>
                </div>
            <% } else { %>
                <form method="post" action="<%= ctx %>/thungan/doTaoDon.jsp" class="row">
                    <input type="hidden" name="action" value="apKM">
                    <label for="ma">Mã khuyến mãi</label>
                    <input type="text" id="ma" name="maCode" placeholder="GIAM20K" maxlength="20">
                    <button class="btn btn-ghost">Áp dụng</button>
                </form>
            <% } %>
        </div>

        <div class="box">
            <div class="sum"><span>Tổng tiền:</span><span><%= Web.tien(dh.getTongTien()) %></span></div>
            <div class="sum"><span>Giảm giá:</span><span><%= dh.getGiamGia() > 0 ? "−" + Web.tien(dh.getGiamGia()) : "0" %></span></div>
            <div class="sum big"><span>THÀNH TIỀN:</span><span><%= Web.tien(dh.getThanhTien()) %></span></div>
        </div>

        <div class="actions">
            <form method="post" action="<%= ctx %>/thungan/doTaoDon.jsp">
                <input type="hidden" name="action" value="huy">
                <button class="btn btn-ghost btn-lg" style="width:100%">Hủy đơn</button>
            </form>
            <form method="post" action="<%= ctx %>/thungan/doTaoDon.jsp">
                <input type="hidden" name="action" value="thanhToan">
                <button class="btn btn-lg" style="width:100%" <%= dh.getDsChiTiet().isEmpty() ? "disabled" : "" %>>THANH TOÁN</button>
            </form>
        </div>
    </div>
</div>

<%-- Hộp thoại chọn tùy chọn món (GDChonTuyChon) – mỗi món một hộp thoại --%>
<% for (SanPham sp : menu) { if (!sp.isDangBan()) continue; %>
<dialog id="d<%= sp.getId() %>">
    <form method="post" action="<%= ctx %>/thungan/doTaoDon.jsp">
        <input type="hidden" name="action" value="them">
        <div class="hd"><%= Web.h(sp.getTen()) %></div>
        <div class="bd">
            <fieldset><legend>Kích cỡ</legend><div class="chips">
                <% for (int i = 0; i < sp.getDsGia().size(); i++) { SanPhamKichCo g = sp.getDsGia().get(i);
                   boolean chon = "M".equals(g.getKichCo().getMa()) || (i == 0 && sp.getDsGia().size() == 1); %>
                <label><input type="radio" name="idSPKC" value="<%= g.getId() %>" <%= chon ? "checked" : "" %> required>
                    <span><%= g.getKichCo().getMa() %> · <%= Web.tien(g.getGia()) %></span></label>
                <% } %>
            </div></fieldset>
            <fieldset><legend>Mức đường</legend><div class="chips">
                <% for (String d : mucDuong) { %>
                <label><input type="radio" name="mucDuong" value="<%= d %>" <%= "100".equals(d) ? "checked" : "" %>><span><%= d %>%</span></label>
                <% } %>
            </div></fieldset>
            <fieldset><legend>Mức đá</legend><div class="chips">
                <% for (String d : mucDa) { %>
                <label><input type="radio" name="mucDa" value="<%= d %>" <%= "Vừa".equals(d) ? "checked" : "" %>><span><%= d %></span></label>
                <% } %>
            </div></fieldset>
            <fieldset><legend>Topping</legend><div class="chips">
                <% for (Topping t : dsTopping) { %>
                <label><input type="checkbox" name="topping" value="<%= t.getId() %>"><span><%= Web.h(t.getTen()) %> +<%= Web.tien(t.getGia()) %></span></label>
                <% } %>
            </div></fieldset>
            <fieldset><legend>Số lượng</legend>
                <input type="number" name="soLuong" value="1" min="1" max="50" required style="width:90px">
            </fieldset>
        </div>
        <div class="ft">
            <button type="button" class="btn btn-ghost" data-close>Đóng</button>
            <button class="btn">Thêm vào đơn</button>
        </div>
    </form>
</dialog>
<% } %>

<script>
    document.querySelectorAll('#tabs button').forEach(function (b) {
        b.addEventListener('click', function () {
            document.querySelectorAll('#tabs button').forEach(function (x) { x.classList.remove('on'); });
            document.querySelectorAll('.menu').forEach(function (m) { m.hidden = true; });
            b.classList.add('on');
            document.getElementById(b.dataset.tab).hidden = false;
        });
    });
    document.querySelectorAll('[data-dlg]').forEach(function (b) {
        b.addEventListener('click', function () { document.getElementById(b.dataset.dlg).showModal(); });
    });
    document.querySelectorAll('[data-close]').forEach(function (b) {
        b.addEventListener('click', function () { b.closest('dialog').close(); });
    });
</script>
<%@include file="/Footer.jsp"%>
