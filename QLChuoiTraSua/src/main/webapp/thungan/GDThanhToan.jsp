<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.*, util.Web"%>
<%
    NhanVien nv = Web.yeuCau(request, response, NhanVien.THU_NGAN);
    if (nv == null) return;
    DonHang dh = (DonHang) session.getAttribute("donHang");
    if (dh == null || dh.getDsChiTiet().isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/thungan/GDTaoDon.jsp");
        return;
    }
    dh.capNhatTien();
    String tieuDe = "Thanh toán";
%>
<%@include file="/Header.jsp"%>
<div class="pay card">
    <h1>THANH TOÁN ĐƠN HÀNG</h1>
    <table class="tbl">
        <tr><th>Món</th><th class="num">SL</th><th class="num">Thành tiền</th></tr>
        <% for (ChiTietDonHang ct : dh.getDsChiTiet()) { %>
        <tr>
            <td><%= Web.h(ct.getSanPhamKichCo().getSanPham().getTen()) %> (<%= ct.getSanPhamKichCo().getKichCo().getMa() %>)
                <div class="muted"><%= ct.getMucDuong() %>% đường · <%= Web.h(ct.getMucDa()) %> đá<%= ct.getDsTopping().isEmpty() ? "" : " · + " + Web.h(ct.getMoTaTopping()) %></div></td>
            <td class="num"><%= ct.getSoLuong() %></td>
            <td class="num"><%= Web.tien(ct.getThanhTien()) %></td>
        </tr>
        <% } %>
    </table>
    <div style="margin:12px 0">
        <% if (dh.getKhachHang() != null) { %><div class="sum"><span>Thành viên:</span><span class="tv"><%= Web.h(dh.getKhachHang().getHoTen()) %></span></div><% } %>
        <div class="sum"><span>Tổng tiền:</span><span><%= Web.tien(dh.getTongTien()) %></span></div>
        <div class="sum"><span>Giảm giá<%= dh.getKhuyenMai() == null ? "" : " (" + Web.h(dh.getKhuyenMai().getMaCode()) + ")" %>:</span><span><%= dh.getGiamGia() > 0 ? "−" + Web.tien(dh.getGiamGia()) : "0" %></span></div>
        <div class="sum big"><span>Thành tiền:</span><span><%= Web.tien(dh.getThanhTien()) %> đ</span></div>
    </div>
    <form method="post" action="<%= request.getContextPath() %>/thungan/doThanhToan.jsp" id="f">
        <div class="row" style="margin-bottom:12px">
            <label><input type="radio" name="phuongThuc" value="TienMat" checked> Tiền mặt</label>
            <label><input type="radio" name="phuongThuc" value="ChuyenKhoan"> Chuyển khoản (QR)</label>
        </div>
        <div id="tienMat">
            <div class="row">
                <label for="tien" style="width:130px">Tiền khách đưa</label>
                <input type="text" id="tien" name="tienKhachDua" inputmode="numeric" autocomplete="off" style="flex:1">
            </div>
            <div class="sum" style="margin-top:10px"><span>Tiền thừa:</span><b id="thua">0 đ</b></div>
        </div>
        <div id="qr" class="qr" hidden>
            <div style="font-size:40px">▦</div>
            Quét mã QR để chuyển khoản <b><%= Web.tien(dh.getThanhTien()) %> đ</b><br>
            <span class="muted">Thu ngân bấm Xác nhận khi thấy tiền đã vào tài khoản.</span>
        </div>
        <div class="actions">
            <a class="btn btn-ghost btn-lg" href="<%= request.getContextPath() %>/thungan/GDTaoDon.jsp">Quay lại</a>
            <button class="btn btn-lg" id="xn">XÁC NHẬN</button>
        </div>
    </form>
</div>
<script>
    var thanhTien = <%= dh.getThanhTien() %>;
    var tien = document.getElementById('tien'), thua = document.getElementById('thua');
    function so(s) { return parseInt(String(s).replace(/[^0-9]/g, ''), 10) || 0; }
    function fmt(n) { return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.'); }
    tien.addEventListener('input', function () {
        var v = so(tien.value);
        tien.value = v ? fmt(v) : '';
        var t = v - thanhTien;
        thua.textContent = (t >= 0 ? fmt(t) + ' đ' : 'Chưa đủ ' + fmt(-t) + ' đ');
        thua.style.color = t >= 0 ? '' : '#c62828';
    });
    document.querySelectorAll('input[name=phuongThuc]').forEach(function (r) {
        r.addEventListener('change', function () {
            var ck = document.querySelector('input[name=phuongThuc]:checked').value === 'ChuyenKhoan';
            document.getElementById('qr').hidden = !ck;
            document.getElementById('tienMat').hidden = ck;
        });
    });
</script>
<%@include file="/Footer.jsp"%>
