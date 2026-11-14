/**
 * ShipFood — Oracle 23ai JSON Relational Duality View & ORDS Client
 * Tương thích ORDS REST API sinh tự động từ Oracle Database 23ai.
 */

// ==========================================
// 1. DỮ LIỆU MOCK CHUẨN ORACLE 23ai
// ==========================================
const MOCK_DATA = {
  orders: [
    {
      _id: 1,
      ngaydathang: "2026-11-14T08:30:00Z",
      trangthai: "Chờ xác nhận",
      tongtien: 115000,
      phiship: 15000,
      phidichvu: 5000,
      ghichu: "Giao tại tầng 3, gọi trước khi đến",
      ngaygiaohang: null,
      ngaythanhtoan: null,
      momoTransId: null,
      quanAn: {
        userid: 101,
        tenquanan: "Cơm Tấm Ba Ghiền",
        diachi: "84 Đặng Văn Ngữ, P.10, Q.Phú Nhuận"
      },
      giaoHang: {
        mattdh: 201,
        tennguoinhan: "Nguyễn Văn An",
        sdt: "0901234567",
        diachi: "123 Lê Lợi, P.Bến Nghé, Q.1, TP.HCM",
        toado: "10.7769, 106.7009",
        userid: 301
      },
      thanhToan: {
        mahttt: 1,
        tenhinhthuc: "Ví điện tử ShipFood"
      },
      shipper: {
        userid: 401,
        tenshipper: "Trần Minh Shipper"
      },
      khuyenMai: {
        makm: 1,
        tenkm: "FREESHIP Giờ Vàng",
        phantramgiam: 10
      },
      chiTiet: [
        {
          mactdh: 5001,
          soluong: 1,
          dongia: 65000,
          bienThe: {
            id: 11,
            tensize: "Đặc biệt",
            giatien: 65000,
            monAn: {
              mamon: 1,
              tenmon: "Cơm Tấm Sườn Bì Chả",
              hinhanh: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200"
            }
          },
          danhGia: []
        },
        {
          mactdh: 5002,
          soluong: 2,
          dongia: 15000,
          bienThe: {
            id: 12,
            tensize: "Ly lớn",
            giatien: 15000,
            monAn: {
              mamon: 2,
              tenmon: "Trà Tắc Xí Muội",
              hinhanh: "https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=200"
            }
          },
          danhGia: []
        }
      ]
    },
    {
      _id: 2,
      ngaydathang: "2026-11-14T09:15:00Z",
      trangthai: "Đang giao",
      tongtien: 160000,
      phiship: 20000,
      phidichvu: 5000,
      ghichu: "Để đồ trước cửa phòng 402",
      ngaygiaohang: null,
      ngaythanhtoan: "2026-11-14T09:16:12Z",
      momoTransId: "MM202611140916",
      quanAn: {
        userid: 102,
        tenquanan: "Phở Thìn Lò Đúc - Chi Nhánh HCM",
        diachi: "110 Hai Bà Trưng, P.Đa Kao, Q.1"
      },
      giaoHang: {
        mattdh: 202,
        tennguoinhan: "Lê Thị Thuỷ",
        sdt: "0912345678",
        diachi: "456 Nam Kỳ Khởi Nghĩa, Q.3, TP.HCM",
        toado: "10.7892, 106.6853",
        userid: 302
      },
      thanhToan: {
        mahttt: 3,
        tenhinhthuc: "MoMo Online"
      },
      shipper: {
        userid: 402,
        tenshipper: "Phạm Hùng Giao Hàng"
      },
      khuyenMai: null,
      chiTiet: [
        {
          mactdh: 5003,
          soluong: 2,
          dongia: 67500,
          bienThe: {
            id: 21,
            tensize: "Tô lớn",
            giatien: 67500,
            monAn: {
              mamon: 3,
              tenmon: "Phở Bò Tái Lăn",
              hinhanh: "https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=200"
            }
          },
          danhGia: []
        }
      ]
    },
    {
      _id: 3,
      ngaydathang: "2026-11-14T07:45:00Z",
      trangthai: "Hoàn thành",
      tongtien: 80000,
      phiship: 10000,
      phidichvu: 5000,
      ghichu: "",
      ngaygiaohang: "2026-11-14T08:20:00Z",
      ngaythanhtoan: "2026-11-14T07:46:00Z",
      momoTransId: null,
      quanAn: {
        userid: 103,
        tenquanan: "Bánh Mì Huỳnh Hoa",
        diachi: "26 Lê Thị Riêng, P.Bến Thành, Q.1"
      },
      giaoHang: {
        mattdh: 203,
        tennguoinhan: "Võ Văn Kiệt",
        sdt: "0987654321",
        diachi: "88 Hàm Nghi, Q.1, TP.HCM",
        toado: "10.7712, 106.7028",
        userid: 303
      },
      thanhToan: {
        mahttt: 2,
        tenhinhthuc: "Tiền mặt khi nhận (COD)"
      },
      shipper: {
        userid: 401,
        tenshipper: "Trần Minh Shipper"
      },
      khuyenMai: null,
      chiTiet: [
        {
          mactdh: 5004,
          soluong: 1,
          dongia: 65000,
          bienThe: {
            id: 31,
            tensize: "Tiêu chuẩn",
            giatien: 65000,
            monAn: {
              mamon: 4,
              tenmon: "Bánh Mì Thịt Chả Đặc Biệt",
              hinhanh: "https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=200"
            }
          },
          danhGia: [
            {
              madg: 901,
              diemdanhgia: 5,
              nhanxet: "Bánh mì giòn rụm, pa-tê béo ngậy rất ngon!",
              hinhanh: null,
              ngaydanhgia: "2026-11-14T08:35:00Z",
              phanHoiCuaQuan: "Cảm ơn bạn đã ủng hộ quán!"
            }
          ]
        }
      ]
    }
  ],

  customers: [
    {
      _id: 301,
      tenkh: "Nguyễn Văn An",
      hinhanh: null,
      taiKhoan: {
        userid: 301,
        username: "an_nguyen",
        email: "an.nguyen@example.com",
        sdt: "0901234567",
        trangthai: "Active"
      },
      diaChi: [
        {
          mattdh: 201,
          tennguoinhan: "Nguyễn Văn An",
          sdt: "0901234567",
          diachi: "123 Lê Lợi, P.Bến Nghé, Q.1, TP.HCM",
          toado: "10.7769, 106.7009"
        }
      ]
    },
    {
      _id: 302,
      tenkh: "Lê Thị Thuỷ",
      hinhanh: null,
      taiKhoan: {
        userid: 302,
        username: "thuy_le",
        email: "thuy.le@example.com",
        sdt: "0912345678",
        trangthai: "Active"
      },
      diaChi: [
        {
          mattdh: 202,
          tennguoinhan: "Lê Thị Thuỷ",
          sdt: "0912345678",
          diachi: "456 Nam Kỳ Khởi Nghĩa, Q.3, TP.HCM",
          toado: "10.7892, 106.6853"
        }
      ]
    }
  ],

  menu: [
    {
      _id: 1,
      tenmon: "Cơm Tấm Sườn Bì Chả",
      mota: "Sườn nướng mật ong thơm phức ăn kèm chả trứng và bì dai ngon",
      hinhanh: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300",
      conhang: 1,
      quanAn: { userid: 101, tenquanan: "Cơm Tấm Ba Ghiền" },
      danhMuc: { madanhmuc: 1, tendanhmuc: "Cơm & Món chính" },
      bienThe: [
        { id: 11, tensize: "Tiêu chuẩn", giatien: 55000, khuyenMai: [] },
        { id: 12, tensize: "Đặc biệt", giatien: 65000, khuyenMai: [] }
      ]
    },
    {
      _id: 3,
      tenmon: "Phở Bò Tái Lăn",
      mota: "Thịt bò xào lăn thơm bùi với tỏi gừng, nước dùng đậm đà",
      hinhanh: "https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=300",
      conhang: 1,
      quanAn: { userid: 102, tenquanan: "Phở Thìn Lò Đúc" },
      danhMuc: { madanhmuc: 2, tendanhmuc: "Bún & Phở" },
      bienThe: [
        { id: 21, tensize: "Tô thường", giatien: 60000, khuyenMai: [] },
        { id: 22, tensize: "Tô lớn", giatien: 70000, khuyenMai: [] }
      ]
    }
  ]
};

// State Machine Quy tắc chuyển đổi (tương ứng với trg_kiem_soat_trang_thai_don)
const STATE_TRANSITIONS = {
  "Chờ xác nhận": ["Đã đặt", "Hủy đơn"],
  "Đã đặt": ["Đang chuẩn bị", "Đang giao", "Hủy đơn"],
  "Đang chuẩn bị": ["Đang giao", "Hủy đơn"],
  "Đang giao": ["Hoàn thành", "Hủy đơn"],
  "Hoàn thành": [],
  "Hủy đơn": []
};

const ALL_STATES = ["Chờ xác nhận", "Đã đặt", "Đang chuẩn bị", "Đang giao", "Hoàn thành", "Hủy đơn"];

// ==========================================
// 2. BIẾN TRẠNG THÁI TOÀN CỤC
// ==========================================
let currentOrders = JSON.parse(JSON.stringify(MOCK_DATA.orders));
let currentSelectedOrder = null;
let isLiveMode = false;

// ==========================================
// 3. KHỞI TẠO VÀ GẮN SỰ KIỆN
// ==========================================
document.addEventListener("DOMContentLoaded", () => {
  initEventListeners();
  renderOrdersTable();
  renderKPIs();
  renderCustomers();
  renderMenu();
  populateCreateOrderDropdowns();
});

function initEventListeners() {
  // Tabs
  document.querySelectorAll(".tab-btn").forEach(btn => {
    btn.addEventListener("click", () => {
      document.querySelectorAll(".tab-btn").forEach(b => b.classList.remove("active"));
      document.querySelectorAll(".tab-content").forEach(c => c.classList.remove("active"));
      btn.classList.add("active");
      const tabId = btn.getAttribute("data-tab");
      document.getElementById(tabId).classList.add("active");
    });
  });

  // Modal subtabs
  document.querySelectorAll(".subtab-btn").forEach(btn => {
    btn.addEventListener("click", () => {
      document.querySelectorAll(".subtab-btn").forEach(b => b.classList.remove("active"));
      document.querySelectorAll(".subtab-content").forEach(c => c.classList.remove("active"));
      btn.classList.add("active");
      const subId = btn.getAttribute("data-subtab");
      document.getElementById(subId).classList.add("active");
    });
  });

  // Modal close buttons
  document.querySelectorAll("[data-close]").forEach(btn => {
    btn.addEventListener("click", () => {
      const modalId = btn.getAttribute("data-close");
      document.getElementById(modalId).classList.remove("active");
    });
  });

  // Mode select
  document.getElementById("modeSelect").addEventListener("change", (e) => {
    isLiveMode = (e.target.value === "live");
    updateConnectionIndicator();
    log(`Chuyển chế độ hoạt động: ${isLiveMode ? "LIVE ORDS (Oracle 23ai)" : "MOCK DATA"}`, "info");
    if (isLiveMode) {
      testOrdsConnection();
    }
  });

  // Test connection button
  document.getElementById("btnTestConn").addEventListener("click", testOrdsConnection);

  // Reload data
  document.getElementById("btnReloadData").addEventListener("click", fetchOrders);

  // Clear log
  document.getElementById("btnClearLog").addEventListener("click", () => {
    document.getElementById("logConsole").innerHTML = "";
    log("Đã dọn sạch console.", "info");
  });

  // Create order modal
  document.getElementById("btnOpenCreateModal").addEventListener("click", () => {
    document.getElementById("createOrderModal").classList.add("active");
    initOrderItemsBuilder();
  });

  document.getElementById("btnAddItemRow").addEventListener("click", addItemRow);
  document.getElementById("btnSubmitOrder").addEventListener("click", submitCreateOrder);

  // Boundary test button
  document.getElementById("btnTestBoundaryUpdate").addEventListener("click", testBoundaryViolation);
}

// ==========================================
// 4. KẾT NỐI ORDS & GỌI REST API
// ==========================================
function getBaseUrl() {
  return document.getElementById("ordsUrl").value.trim().replace(/\/$/, "");
}

function updateConnectionIndicator(status = null) {
  const dot = document.getElementById("connDot");
  const txt = document.getElementById("connStatusText");

  dot.className = "dot";
  if (!isLiveMode) {
    dot.classList.add("mock");
    txt.textContent = "Đang dùng Mock Data";
  } else if (status === "connected") {
    txt.textContent = "Đã kết nối ORDS Live";
  } else {
    dot.classList.add("offline");
    txt.textContent = "Chưa kết nối ORDS (Offline)";
  }
}

async function testOrdsConnection() {
  const url = `${getBaseUrl()}/dv_don_hang/`;
  log(`[HTTP GET] Kiểm tra kết nối tới: ${url}`, "info");

  try {
    const res = await fetch(url, { headers: { "Accept": "application/json" } });
    if (res.ok) {
      log(`Kết nối ORDS thành công (HTTP ${res.status}). Đang nhận dữ liệu từ Oracle 23ai.`, "success");
      updateConnectionIndicator("connected");
      fetchOrders();
    } else {
      throw new Error(`HTTP ${res.status}: ${res.statusText}`);
    }
  } catch (err) {
    log(`Không thể kết nối ORDS tại ${url}. Chi tiết: ${err.message}`, "warning");
    log(`Tự động duy trì dữ liệu mô phỏng chuẩn Oracle 23ai Duality View để demo.`, "info");
    updateConnectionIndicator("offline");
  }
}

async function fetchOrders() {
  if (!isLiveMode) {
    renderOrdersTable();
    renderKPIs();
    log("Đã tải lại dữ liệu từ bộ nhớ Mock.", "info");
    return;
  }

  const url = `${getBaseUrl()}/dv_don_hang/`;
  log(`[HTTP GET] Lấy danh sách đơn: ${url}`, "info");

  try {
    const res = await fetch(url, { headers: { "Accept": "application/json" } });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = await res.json();
    currentOrders = data.items || data;
    renderOrdersTable();
    renderKPIs();
    log(`Đã tải thành công ${currentOrders.length} đơn hàng từ ORDS.`, "success");
  } catch (err) {
    log(`Lỗi tải đơn từ ORDS: ${err.message}. Tiếp tục hiển thị dữ liệu hiện có.`, "error");
  }
}

// ==========================================
// 5. HIỂN THỊ DANH SÁCH & MODAL CHI TIẾT
// ==========================================
function renderOrdersTable() {
  const tbody = document.getElementById("ordersTableBody");
  tbody.innerHTML = "";

  currentOrders.forEach(o => {
    const tr = document.createElement("tr");
    const statusClass = getStatusClass(o.trangthai);

    tr.innerHTML = `
      <td><strong>#${o._id}</strong></td>
      <td>${formatDateTime(o.ngaydathang)}</td>
      <td>${o.quanAn ? escapeHtml(o.quanAn.tenquanan) : "N/A"}</td>
      <td>${o.giaoHang ? escapeHtml(o.giaoHang.tennguoinhan) : "N/A"}</td>
      <td><span class="badge badge-status ${statusClass}">${escapeHtml(o.trangthai)}</span></td>
      <td><strong>${formatCurrency(o.tongtien)}</strong></td>
      <td>${o.thanhToan ? escapeHtml(o.thanhToan.tenhinhthuc) : "N/A"}</td>
      <td>
        <div class="btn-group">
          <button class="btn btn-secondary btn-sm" onclick="viewOrderJson(${o._id})">🔍 JSON 3 cấp</button>
          <button class="btn btn-primary btn-sm" onclick="openStatusModal(${o._id})">⚙ Đổi trạng thái</button>
        </div>
      </td>
    `;
    tbody.appendChild(tr);
  });
}

function renderKPIs() {
  const total = currentOrders.length;
  const processing = currentOrders.filter(o => o.trangthai === "Đang chuẩn bị" || o.trangthai === "Đang giao").length;
  const completed = currentOrders.filter(o => o.trangthai === "Hoàn thành").length;
  const revenue = currentOrders.filter(o => o.trangthai === "Hoàn thành").reduce((acc, cur) => acc + (cur.tongtien || 0), 0);

  document.getElementById("kpiTotalOrders").textContent = total;
  document.getElementById("kpiProcessingOrders").textContent = processing;
  document.getElementById("kpiCompletedOrders").textContent = completed;
  document.getElementById("kpiTotalRevenue").textContent = formatCurrency(revenue);
}

window.viewOrderJson = function(orderId) {
  const order = currentOrders.find(o => o._id === orderId);
  if (!order) return;
  currentSelectedOrder = order;

  document.getElementById("jsonModalTitle").textContent = `Chi tiết Đơn hàng #${order._id} — JSON Relational Duality View`;
  document.getElementById("rawJsonCode").textContent = JSON.stringify(order, null, 2);

  // Build interactive Tree View
  const treeContainer = document.getElementById("treeViewContainer");
  treeContainer.innerHTML = buildTreeHtml(order);

  document.getElementById("jsonModal").classList.add("active");
  log(`[UI] Đã mở xem cấu trúc JSON Relational Duality View của đơn hàng #${order._id}`, "info");
};

function buildTreeHtml(obj) {
  let html = `<div class="tree-root">`;
  html += `<div class="tree-node"><span class="tree-key">Mã Đơn hàng (_id):</span> <span class="tree-val">#${obj._id}</span></div>`;
  html += `<div class="tree-node"><span class="tree-key">Trạng thái:</span> <span class="badge badge-status ${getStatusClass(obj.trangthai)}">${obj.trangthai}</span></div>`;
  html += `<div class="tree-node"><span class="tree-key">Tổng tiền:</span> <span class="tree-val">${formatCurrency(obj.tongtien)}</span> (Ship: ${formatCurrency(obj.phiship)}, DV: ${formatCurrency(obj.phidichvu)})</div>`;
  
  if (obj.quanAn) {
    html += `
      <div class="tree-node">
        <span class="tree-key">Quán ăn (tbQuanAn - NOUPDATE):</span>
        <span class="tree-badge">${escapeHtml(obj.quanAn.tenquanan)}</span> — ${escapeHtml(obj.quanAn.diachi)}
      </div>
    `;
  }
  if (obj.giaoHang) {
    html += `
      <div class="tree-node">
        <span class="tree-key">Giao nhận (tbThongTinDatHang):</span>
        ${escapeHtml(obj.giaoHang.tennguoinhan)} (${escapeHtml(obj.giaoHang.sdt)}) — ${escapeHtml(obj.giaoHang.diachi)}
      </div>
    `;
  }
  if (obj.thanhToan) {
    html += `<div class="tree-node"><span class="tree-key">Hình thức thanh toán:</span> ${escapeHtml(obj.thanhToan.tenhinhthuc)}</div>`;
  }
  if (obj.shipper) {
    html += `<div class="tree-node"><span class="tree-key">Shipper:</span> ${escapeHtml(obj.shipper.tenshipper)}</div>`;
  }

  // Nested ChiTiet (WITH INSERT UPDATE DELETE)
  html += `<div class="tree-node" style="margin-top: 10px;"><strong class="tree-key">Chi tiết đơn hàng (tbChiTietDonHang - Lồng 3 Cấp):</strong>`;
  if (obj.chiTiet && obj.chiTiet.length > 0) {
    obj.chiTiet.forEach((ct, idx) => {
      const mon = ct.bienThe && ct.bienThe.monAn ? ct.bienThe.monAn.tenmon : "Món ăn";
      const size = ct.bienThe ? ct.bienThe.tensize : "N/A";
      html += `
        <div class="tree-node" style="padding-left: 16px; border-left: 2px solid #cbd5e1; margin-top: 6px;">
          <div><strong>Mục ${idx + 1}:</strong> ${escapeHtml(mon)} (Size: ${escapeHtml(size)})</div>
          <div>Số lượng: ${ct.soluong} × Đơn giá: ${formatCurrency(ct.dongia)} = <strong>${formatCurrency(ct.soluong * ct.dongia)}</strong></div>
      `;
      if (ct.danhGia && ct.danhGia.length > 0) {
        ct.danhGia.forEach(dg => {
          html += `
            <div style="font-size: 0.8rem; background: #fefce8; padding: 4px 8px; border-radius: 4px; margin-top: 4px;">
              ⭐ Đánh giá: ${dg.diemdanhgia}/5 sao — "${escapeHtml(dg.nhanxet || "")}"
              ${dg.phanHoiCuaQuan ? `<br><em>Phản hồi quán: ${escapeHtml(dg.phanHoiCuaQuan)}</em>` : ""}
            </div>
          `;
        });
      }
      html += `</div>`;
    });
  } else {
    html += `<div style="padding-left: 16px; color: #94a3b8;">(Chưa có món nào)</div>`;
  }
  html += `</div>`;
  html += `</div>`;
  return html;
}

// ==========================================
// 6. XỬ LÝ STATE MACHINE VÀ BOUNDARY TRIGGER
// ==========================================
window.openStatusModal = function(orderId) {
  const order = currentOrders.find(o => o._id === orderId);
  if (!order) return;
  currentSelectedOrder = order;

  document.getElementById("statusModalOrderId").textContent = `#${order._id}`;
  const badge = document.getElementById("statusModalCurrentBadge");
  badge.textContent = order.trangthai;
  badge.className = `badge badge-status ${getStatusClass(order.trangthai)}`;

  // Allowed next states
  const validContainer = document.getElementById("validStateButtons");
  validContainer.innerHTML = "";
  const allowed = STATE_TRANSITIONS[order.trangthai] || [];

  if (allowed.length === 0) {
    validContainer.innerHTML = `<span class="hint-text">Đơn hàng đã kết thúc (không thể chuyển trạng thái nữa).</span>`;
  } else {
    allowed.forEach(st => {
      const btn = document.createElement("button");
      btn.className = (st === "Hủy đơn") ? "btn btn-danger btn-sm" : "btn btn-success btn-sm";
      btn.textContent = `➡ Sang "${st}"`;
      btn.onclick = () => updateOrderStatus(order._id, st, true);
      validContainer.appendChild(btn);
    });
  }

  // Invalid states (to demonstrate trigger ORA-20010)
  const invalidContainer = document.getElementById("invalidStateButtons");
  invalidContainer.innerHTML = "";
  const forbidden = ALL_STATES.filter(st => st !== order.trangthai && !allowed.includes(st));

  forbidden.forEach(st => {
    const btn = document.createElement("button");
    btn.className = "btn btn-secondary btn-sm";
    btn.textContent = `⚡ Chuyển trái phép sang "${st}"`;
    btn.onclick = () => updateOrderStatus(order._id, st, false);
    invalidContainer.appendChild(btn);
  });

  document.getElementById("statusModal").classList.add("active");
};

async function updateOrderStatus(orderId, nextState, isValidTransition) {
  const order = currentOrders.find(o => o._id === orderId);
  if (!order) return;

  const url = `${getBaseUrl()}/dv_don_hang/${orderId}`;
  const payload = { _id: orderId, trangthai: nextState };

  log(`[HTTP PUT] Cập nhật trạng thái đơn #${orderId} sang "${nextState}"`, "info");
  log(`Payload: ${JSON.stringify(payload)}`, "info");

  if (isLiveMode) {
    try {
      const res = await fetch(url, {
        method: "PUT",
        headers: { "Content-Type": "application/json", "Accept": "application/json" },
        body: JSON.stringify(payload)
      });
      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.message || JSON.stringify(data));
      }
      log(`Cập nhật thành công đơn #${orderId} -> "${nextState}"`, "success");
      order.trangthai = nextState;
      renderOrdersTable();
      renderKPIs();
      document.getElementById("statusModal").classList.remove("active");
    } catch (err) {
      log(`[ORDS ERROR] Trigger từ chối thao tác: ${err.message}`, "error");
      alert(`[ORDS Database Error]\n${err.message}`);
    }
  } else {
    // Mock simulation
    if (isValidTransition) {
      order.trangthai = nextState;
      if (nextState === "Đã đặt") order.ngaythanhtoan = new Date().toISOString();
      if (nextState === "Hoàn thành") order.ngaygiaohang = new Date().toISOString();
      renderOrdersTable();
      renderKPIs();
      log(`[MOCK SUCCESS] Trigger trg_kiem_soat_trang_thai_don chấp thuận. Đơn #${orderId} -> "${nextState}".`, "success");
      document.getElementById("statusModal").classList.remove("active");
    } else {
      const errorMsg = `ORA-20010: Không được phép chuyển trạng thái từ "${order.trangthai}" sang "${nextState}"\nORA-06512: tại "SHIPFOOD.TRG_KIEM_SOAT_TRANG_THAI_DON", dòng 24`;
      log(`[MOCK TRIGGER VIOLATION] ${errorMsg}`, "error");
      alert(`[Oracle 23ai Database Trigger Error]\n${errorMsg}`);
    }
  }
}

async function testBoundaryViolation() {
  if (!currentSelectedOrder) return;
  const orderId = currentSelectedOrder._id;
  const url = `${getBaseUrl()}/dv_don_hang/${orderId}`;
  const payload = {
    _id: orderId,
    quanAn: {
      userid: 101,
      tenquanan: "Tên quán bị sửa bất hợp pháp"
    }
  };

  log(`[HTTP PUT] Kiểm tra giới hạn Duality View: sửa trường quanAn (WITH NOUPDATE)`, "info");
  log(`Payload: ${JSON.stringify(payload)}`, "info");

  if (isLiveMode) {
    try {
      const res = await fetch(url, {
        method: "PUT",
        headers: { "Content-Type": "application/json", "Accept": "application/json" },
        body: JSON.stringify(payload)
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.message || JSON.stringify(data));
      log(`Thành công ngoài dự kiến`, "warning");
    } catch (err) {
      log(`[ORDS BOUNDARY REJECTED] Oracle 23ai từ chối cập nhật thuộc tính NOUPDATE: ${err.message}`, "error");
      alert(`[Oracle Duality View Boundary Error]\n${err.message}`);
    }
  } else {
    const errorMsg = `ORA-42399: cannot perform update on read-only relational table "TBQUANAN" mapped via JSON Relational Duality View "DV_DON_HANG"`;
    log(`[MOCK BOUNDARY REJECTED] ${errorMsg}`, "error");
    alert(`[Oracle 23ai Duality View Security Constraint]\n${errorMsg}`);
  }
}

// ==========================================
// 7. FORM TẠO ĐƠN HÀNG MỚI (POST DUALITY VIEW)
// ==========================================
function populateCreateOrderDropdowns() {
  const qSelect = document.getElementById("formQuanAn");
  qSelect.innerHTML = `
    <option value="101">Cơm Tấm Ba Ghiền (Quận Phú Nhuận)</option>
    <option value="102">Phở Thìn Lò Đúc (Quận 1)</option>
    <option value="103">Bánh Mì Huỳnh Hoa (Quận 1)</option>
  `;

  const kSelect = document.getElementById("formKhachHang");
  kSelect.innerHTML = `
    <option value="301" data-addr="123 Lê Lợi, Q.1">Nguyễn Văn An (0901234567)</option>
    <option value="302" data-addr="456 Nam Kỳ Khởi Nghĩa, Q.3">Lê Thị Thuỷ (0912345678)</option>
    <option value="303" data-addr="88 Hàm Nghi, Q.1">Võ Văn Kiệt (0987654321)</option>
  `;
}

function initOrderItemsBuilder() {
  const container = document.getElementById("orderItemsContainer");
  container.innerHTML = "";
  addItemRow();
}

function addItemRow() {
  const container = document.getElementById("orderItemsContainer");
  const div = document.createElement("div");
  div.className = "item-row";
  div.innerHTML = `
    <select class="select-box item-variant">
      <option value="11" data-price="55000">Cơm Tấm Sườn - Size Chuẩn (55.000₫)</option>
      <option value="12" data-price="65000">Cơm Tấm Sườn - Đặc Biệt (65.000₫)</option>
      <option value="21" data-price="60000">Phở Tái Lăn - Tô Thường (60.000₫)</option>
      <option value="31" data-price="65000">Bánh Mì Huỳnh Hoa - Tiêu Chuẩn (65.000₫)</option>
      <option value="13" data-price="15000">Trà Tắc Xí Muội (15.000₫)</option>
    </select>
    <input type="number" class="input-text item-qty" value="1" min="1" max="20" placeholder="Số lượng">
    <input type="text" class="input-text item-price" value="55000" readonly>
    <button type="button" class="btn btn-danger btn-sm" onclick="this.parentElement.remove()">X</button>
  `;

  const variantSelect = div.querySelector(".item-variant");
  const priceInput = div.querySelector(".item-price");
  variantSelect.addEventListener("change", () => {
    const selectedOption = variantSelect.selectedOptions[0];
    priceInput.value = selectedOption.getAttribute("data-price");
  });

  container.appendChild(div);
}

async function submitCreateOrder() {
  const quanId = parseInt(document.getElementById("formQuanAn").value);
  const khachId = parseInt(document.getElementById("formKhachHang").value);
  const diachi = document.getElementById("formDiaChi").value;
  const httt = parseInt(document.getElementById("formHTTT").value);
  const ghichu = document.getElementById("formGhiChu").value;

  const itemRows = document.querySelectorAll("#orderItemsContainer .item-row");
  if (itemRows.length === 0) {
    alert("Vui lòng thêm ít nhất 1 món ăn!");
    return;
  }

  let subtotal = 0;
  const chiTiet = [];
  const startId = Date.now() % 100000;

  itemRows.forEach((row, idx) => {
    const select = row.querySelector(".item-variant");
    const variantId = parseInt(select.value);
    const qty = parseInt(row.querySelector(".item-qty").value) || 1;
    const price = parseInt(row.querySelector(".item-price").value) || 0;
    subtotal += (qty * price);

    chiTiet.push({
      mactdh: startId + idx + 1,
      soluong: qty,
      dongia: price,
      bienThe: { id: variantId }
    });
  });

  const phiship = 15000;
  const phidichvu = 5000;
  const newOrderId = Math.floor(Math.random() * 9000) + 1000;

  // Cấu trúc JSON tương thích trực tiếp DV_DON_HANG
  const orderPayload = {
    _id: newOrderId,
    ngaydathang: new Date().toISOString(),
    trangthai: "Chờ xác nhận",
    tongtien: subtotal + phiship + phidichvu,
    phiship: phiship,
    phidichvu: phidichvu,
    ghichu: ghichu,
    quanAn: { userid: quanId },
    giaoHang: {
      mattdh: 200 + (khachId % 10),
      tennguoinhan: document.getElementById("formKhachHang").selectedOptions[0].text.split("(")[0].trim(),
      diachi: diachi,
      userid: khachId
    },
    thanhToan: { mahttt: httt },
    chiTiet: chiTiet
  };

  log(`[HTTP POST] Tạo đơn hàng mới qua DV_DON_HANG`, "info");
  log(`Payload: ${JSON.stringify(orderPayload, null, 2)}`, "info");

  if (isLiveMode) {
    const url = `${getBaseUrl()}/dv_don_hang/`;
    try {
      const res = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json", "Accept": "application/json" },
        body: JSON.stringify(orderPayload)
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.message || JSON.stringify(data));
      log(`Tạo đơn hàng thành công trên Oracle 23ai! ID: #${newOrderId}`, "success");
      fetchOrders();
    } catch (err) {
      log(`Lỗi khi POST đơn hàng lên ORDS: ${err.message}`, "error");
      alert(`[Lỗi ORDS]\n${err.message}`);
      return;
    }
  } else {
    // Add to mock
    // Cung cấp thông tin tên hiển thị cho UI
    orderPayload.quanAn.tenquanan = document.getElementById("formQuanAn").selectedOptions[0].text.split("(")[0].trim();
    orderPayload.thanhToan.tenhinhthuc = document.getElementById("formHTTT").selectedOptions[0].text;
    orderPayload.chiTiet.forEach(ct => {
      ct.bienThe = {
        id: ct.bienThe.id,
        tensize: "Tiêu chuẩn",
        monAn: { tenmon: "Món đặt mới" }
      };
      ct.danhGia = [];
    });

    currentOrders.unshift(orderPayload);
    renderOrdersTable();
    renderKPIs();
    log(`[MOCK POST] Tạo thành công đơn hàng #${newOrderId} với ${chiTiet.length} món lồng nhau.`, "success");
  }

  document.getElementById("createOrderModal").classList.remove("active");
}

// ==========================================
// 8. KHÁCH HÀNG & THỰC ĐƠN
// ==========================================
function renderCustomers() {
  const container = document.getElementById("customersGrid");
  container.innerHTML = "";

  MOCK_DATA.customers.forEach(c => {
    const div = document.createElement("div");
    div.className = "info-card";
    div.innerHTML = `
      <h3>${escapeHtml(c.tenkh)} <small style="color:#64748b;">(#${c._id})</small></h3>
      <p><strong>Email:</strong> ${escapeHtml(c.taiKhoan.email)}</p>
      <p><strong>Điện thoại:</strong> ${escapeHtml(c.taiKhoan.sdt)}</p>
      <h4 style="margin-top: 12px; font-size: 0.9rem;">Sổ địa chỉ giao hàng (Nested diaChi):</h4>
      <ul style="padding-left: 18px; font-size: 0.85rem; margin-top: 6px;">
        ${c.diaChi.map(d => `<li>${escapeHtml(d.tennguoinhan)} — ${escapeHtml(d.diachi)}</li>`).join("")}
      </ul>
    `;
    container.appendChild(div);
  });
}

function renderMenu() {
  const container = document.getElementById("menuGrid");
  container.innerHTML = "";

  MOCK_DATA.menu.forEach(m => {
    const div = document.createElement("div");
    div.className = "info-card";
    div.innerHTML = `
      <h3>${escapeHtml(m.tenmon)}</h3>
      <p style="color:#64748b; font-size: 0.85rem; margin-bottom: 8px;">Quán: <strong>${escapeHtml(m.quanAn.tenquanan)}</strong> | Danh mục: ${escapeHtml(m.danhMuc.tendanhmuc)}</p>
      <p style="font-size: 0.85rem; margin-bottom: 10px;">${escapeHtml(m.mota)}</p>
      <h4 style="font-size: 0.9rem;">Biến thể kích thước &amp; Giá:</h4>
      <div style="display:flex; gap: 8px; margin-top: 6px; flex-wrap: wrap;">
        ${m.bienThe.map(b => `<span class="badge" style="background:#e2e8f0; color:#334155;">${escapeHtml(b.tensize)}: ${formatCurrency(b.giatien)}</span>`).join("")}
      </div>
    `;
    container.appendChild(div);
  });
}

// ==========================================
// 9. LOGGING & TIỆN ÍCH
// ==========================================
function log(msg, type = "info") {
  const consoleEl = document.getElementById("logConsole");
  const time = new Date().toLocaleTimeString();
  const div = document.createElement("div");
  div.className = `log-entry log-${type}`;
  div.textContent = `[${time}] ${msg}`;
  consoleEl.appendChild(div);
  consoleEl.scrollTop = consoleEl.scrollHeight;
}

function getStatusClass(status) {
  switch (status) {
    case "Chờ xác nhận": return "status-cho-xac-nhan";
    case "Đã đặt": return "status-da-dat";
    case "Đang chuẩn bị": return "status-dang-chuan-bi";
    case "Đang giao": return "status-dang-giao";
    case "Hoàn thành": return "status-hoan-thanh";
    case "Hủy đơn": return "status-huy-don";
    default: return "";
  }
}

function formatCurrency(val) {
  return new Intl.NumberFormat("vi-VN", { style: "currency", currency: "VND" }).format(val || 0);
}

function formatDateTime(str) {
  if (!str) return "N/A";
  const d = new Date(str);
  return d.toLocaleString("vi-VN");
}

function escapeHtml(str) {
  if (!str) return "";
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}
