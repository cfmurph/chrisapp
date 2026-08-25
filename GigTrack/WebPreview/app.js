/* GigTrack — browser preview.
 * Mirrors the SwiftUI/SwiftData app's screens & data model so it can be
 * demoed without Xcode. Not part of the iOS build; purely for walkthroughs. */

const STORAGE_KEY = "gigtrack_demo_state_v1";
const CATEGORIES = ["Gear & Equipment", "Travel", "Lodging", "Meals", "Venue", "Marketing", "Supplies", "Other"];
const CATEGORY_ICON = {
  "Gear & Equipment": "🎸", "Travel": "🚗", "Lodging": "🛏️", "Meals": "🍽️",
  "Venue": "🏛️", "Marketing": "📣", "Supplies": "📦", "Other": "🧾"
};

function uid() { return Math.random().toString(36).slice(2, 10); }
function todayISO(offsetDays = 0) {
  const d = new Date();
  d.setDate(d.getDate() + offsetDays);
  return d.toISOString().slice(0, 10);
}
function fmtDate(iso) {
  if (!iso) return "";
  const d = new Date(iso + (iso.length === 10 ? "T00:00:00" : ""));
  return d.toLocaleDateString(undefined, { month: "short", day: "numeric", year: "numeric" });
}
function fmtCurrency(n) {
  const code = state.settings.currency || "USD";
  try {
    return new Intl.NumberFormat(undefined, { style: "currency", currency: code }).format(n || 0);
  } catch (e) {
    return "$" + (n || 0).toFixed(2);
  }
}
function fmtDuration(seconds) {
  seconds = Math.max(0, Math.round(seconds));
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = seconds % 60;
  if (h > 0) return `${h}h ${String(m).padStart(2, "0")}m ${String(s).padStart(2, "0")}s`;
  if (m > 0) return `${m}m ${String(s).padStart(2, "0")}s`;
  return `${s}s`;
}
function fmtHours(seconds) {
  return (seconds / 3600).toFixed(2) + " hrs";
}

function defaultState() {
  const p1 = { id: uid(), name: "Jamie Rivera", role: "Lead Guitar", hourlyRate: 35 };
  const p2 = { id: uid(), name: "Sam Okafor", role: "Sound Engineer", hourlyRate: 40 };
  const c1 = { id: uid(), name: "The Blue Note Club", email: "booking@bluenote.example", phone: "555-0142", address: "123 Jazz St, Austin, TX" };
  const inv1LineItems = [
    { id: uid(), description: "Live performance — 3 sets", qty: 1, price: 850 },
    { id: uid(), description: "Backline rental", qty: 1, price: 120 }
  ];
  return {
    people: [p1, p2],
    clients: [c1],
    receipts: [
      { id: uid(), date: todayISO(-3), vendor: "Guitar Center", amount: 64.99, category: "Gear & Equipment", notes: "New guitar strings + picks", imageData: null },
      { id: uid(), date: todayISO(-8), vendor: "Shell Gas Station", amount: 41.2, category: "Travel", notes: "", imageData: null }
    ],
    invoices: [
      { id: uid(), number: "INV-001", clientId: c1.id, issueDate: todayISO(-10), dueDate: todayISO(4), status: "sent", notes: "Thanks for having us!", paidDate: null, lineItems: inv1LineItems }
    ],
    timeEntries: [
      { id: uid(), personId: p1.id, project: "Blue Note residency", startTime: new Date(Date.now() - 3 * 3600 * 1000).toISOString(), endTime: new Date(Date.now() - 1 * 3600 * 1000).toISOString(), notes: "" }
    ],
    trips: [
      { id: uid(), date: todayISO(-3), start: "Home Studio", end: "The Blue Note Club", miles: 18.4, rate: 0.67, purpose: "Gig load-in", notes: "" }
    ],
    settings: { currency: "USD", businessName: "Jamie Rivera Music", businessEmail: "jamie@example.com", mileageRate: 0.67 },
    runningEntryId: null
  };
}

let state = loadState();
function loadState() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (raw) return JSON.parse(raw);
  } catch (e) {}
  return defaultState();
}
function saveState() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}
function resetDemo() {
  state = defaultState();
  saveState();
  render();
}

// --- Navigation: one stack per tab, plus modal state ---
const stacks = {
  receipts: [{ screen: "list" }],
  invoices: [{ screen: "list" }],
  time: [{ screen: "root" }],
  driving: [{ screen: "list" }],
  settings: [{ screen: "root" }]
};
let currentTab = "receipts";
let modalRenderer = null;
let timerInterval = null;

function switchTab(tab) {
  currentTab = tab;
  document.querySelectorAll(".tab-item").forEach(el => el.classList.toggle("active", el.dataset.tab === tab));
  render();
}
function push(screen, params) {
  stacks[currentTab].push({ screen, ...params });
  render();
}
function pop() {
  if (stacks[currentTab].length > 1) stacks[currentTab].pop();
  render();
}
function topOfStack() {
  const s = stacks[currentTab];
  return s[s.length - 1];
}

function openModal(renderFn) {
  modalRenderer = renderFn;
  document.getElementById("modal").innerHTML = renderFn();
  document.getElementById("modalBackdrop").classList.add("open");
}
function closeModal() {
  document.getElementById("modalBackdrop").classList.remove("open");
  modalRenderer = null;
}
function refreshModal() {
  if (modalRenderer) document.getElementById("modal").innerHTML = modalRenderer();
}

document.getElementById("modalBackdrop").addEventListener("click", (e) => {
  if (e.target.id === "modalBackdrop") closeModal();
});

document.querySelectorAll(".tab-item").forEach(btn => {
  btn.addEventListener("click", () => switchTab(btn.dataset.tab));
});

function setNav(title, { back = false, trailingHtml = "", leadingHtml = "" } = {}) {
  document.getElementById("navTitle").textContent = title;
  const leading = document.getElementById("navLeading");
  const trailing = document.getElementById("navTrailing");
  leading.innerHTML = back ? `<span onclick="pop()">‹ Back</span>${leadingHtml}` : leadingHtml;
  trailing.innerHTML = trailingHtml;
}

function render() {
  clearInterval(timerInterval);
  const screenEl = document.getElementById("screen");
  const view = topOfStack();
  let html = "";

  if (currentTab === "receipts") html = renderReceipts(view);
  else if (currentTab === "invoices") html = renderInvoices(view);
  else if (currentTab === "time") html = renderTime(view);
  else if (currentTab === "driving") html = renderDriving(view);
  else if (currentTab === "settings") html = renderSettings(view);

  screenEl.innerHTML = html;
  saveState();
}

/* ===================== RECEIPTS ===================== */
function renderReceipts(view) {
  setNav("Receipts", { trailingHtml: `<span onclick="openReceiptForm()">＋</span>` });
  const receipts = [...state.receipts].sort((a, b) => b.date.localeCompare(a.date));
  const thisMonth = receipts.filter(r => r.date.slice(0, 7) === todayISO().slice(0, 7)).reduce((s, r) => s + r.amount, 0);
  const allTime = receipts.reduce((s, r) => s + r.amount, 0);

  let rows = "";
  if (receipts.length === 0) {
    rows = emptyState("🧾", "No Receipts Yet", "Tap + to snap or upload a receipt photo and track your expenses.");
  } else {
    rows = `<div class="list-section">` + receipts.map(r => `
      <div class="list-row" onclick="openReceiptForm('${r.id}')">
        <div class="row-thumb">${r.imageData ? `<img src="${r.imageData}"/>` : (CATEGORY_ICON[r.category] || "🧾")}</div>
        <div class="row-main">
          <div class="row-title">${escapeHtml(r.vendor || "Untitled Receipt")}</div>
          <div class="row-sub">${escapeHtml(r.category)}</div>
          <div class="row-sub2">${fmtDate(r.date)}</div>
        </div>
        <div class="row-trail"><div class="row-amount">${fmtCurrency(r.amount)}</div></div>
        <div class="delete-x" onclick="event.stopPropagation(); deleteReceipt('${r.id}')">✕</div>
      </div>`).join("") + `</div>`;
  }

  return `
    ${receipts.length ? statRow([["This Month", fmtCurrency(thisMonth)], ["All Time", fmtCurrency(allTime)]]) : ""}
    ${rows}
  `;
}

function openReceiptForm(id) {
  const existing = id ? state.receipts.find(r => r.id === id) : null;
  const draft = existing ? { ...existing } : { vendor: "", amount: 0, date: todayISO(), category: "Other", notes: "", imageData: null };

  openModal(() => `
    <div class="nav-bar">
      <div class="nav-leading"><span onclick="closeModal()">Cancel</span></div>
      <div class="nav-title">${existing ? "Edit Receipt" : "New Receipt"}</div>
      <div class="nav-trailing"><span onclick="saveReceiptForm('${id || ""}')">Save</span></div>
    </div>
    <div class="form-group">
      <div class="form-row">
        <label>Photo</label>
        <input type="file" accept="image/*" onchange="handleReceiptPhoto(event)" />
      </div>
      ${draft.imageData ? `<div class="form-row"><img src="${draft.imageData}" style="max-width:100%;border-radius:8px;" /></div>` : ""}
    </div>
    <div class="form-group">
      <div class="form-row"><label>Vendor</label><input type="text" id="f_vendor" value="${escapeAttr(draft.vendor)}" placeholder="Vendor" /></div>
      <div class="form-row"><label>Amount</label><input type="number" step="0.01" id="f_amount" value="${draft.amount}" /></div>
      <div class="form-row"><label>Date</label><input type="date" id="f_date" value="${draft.date}" /></div>
      <div class="form-row"><label>Category</label>
        <select id="f_category">${CATEGORIES.map(c => `<option ${c === draft.category ? "selected" : ""}>${c}</option>`).join("")}</select>
      </div>
    </div>
    <div class="form-group">
      <div class="form-row"><textarea id="f_notes" placeholder="Notes">${escapeHtml(draft.notes || "")}</textarea></div>
    </div>
    ${existing ? `<button class="btn btn-danger" onclick="deleteReceipt('${existing.id}'); closeModal();">Delete Receipt</button>` : ""}
  `);
  window.__receiptPhotoData = draft.imageData;
}

function handleReceiptPhoto(e) {
  const file = e.target.files[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = () => {
    window.__receiptPhotoData = reader.result;
    refreshModal();
  };
  reader.readAsDataURL(file);
}

function saveReceiptForm(id) {
  const vendor = document.getElementById("f_vendor").value.trim();
  if (!vendor) { alert("Vendor is required"); return; }
  const data = {
    vendor,
    amount: parseFloat(document.getElementById("f_amount").value) || 0,
    date: document.getElementById("f_date").value || todayISO(),
    category: document.getElementById("f_category").value,
    notes: document.getElementById("f_notes").value,
    imageData: window.__receiptPhotoData || null
  };
  if (id) {
    Object.assign(state.receipts.find(r => r.id === id), data);
  } else {
    state.receipts.push({ id: uid(), ...data });
  }
  closeModal();
  render();
}
function deleteReceipt(id) {
  state.receipts = state.receipts.filter(r => r.id !== id);
  render();
}

/* ===================== INVOICES ===================== */
function renderInvoices(view) {
  if (view.screen === "list") {
    setNav("Invoices", {
      leadingHtml: `<span onclick="push('clients')">Clients</span>`,
      trailingHtml: `<span onclick="openInvoiceForm()">＋</span>`
    });
    const invoices = [...state.invoices].sort((a, b) => b.issueDate.localeCompare(a.issueDate));
    const outstanding = invoices.filter(i => i.status !== "paid").reduce((s, i) => s + invoiceTotal(i), 0);
    const paid = invoices.filter(i => i.status === "paid").reduce((s, i) => s + invoiceTotal(i), 0);

    let rows;
    if (invoices.length === 0) {
      rows = emptyState("📄", "No Invoices Yet", "Create an invoice, send it to a client, and track when it gets paid.");
    } else {
      rows = `<div class="list-section">` + invoices.map(inv => {
        const client = state.clients.find(c => c.id === inv.clientId);
        const status = effectiveStatus(inv);
        return `
        <div class="list-row" onclick="push('detail', {id:'${inv.id}'})">
          <div class="row-main">
            <div class="row-title">#${escapeHtml(inv.number)}</div>
            <div class="row-sub">${escapeHtml(client ? client.name : "No client")}</div>
            <div class="row-sub2">Due ${fmtDate(inv.dueDate)}</div>
          </div>
          <div class="row-trail">
            <div class="row-amount">${fmtCurrency(invoiceTotal(inv))}</div>
            <div class="badge ${status}">${statusLabel(status)}</div>
          </div>
        </div>`;
      }).join("") + `</div>`;
    }
    return `${invoices.length ? statRow([["Outstanding", fmtCurrency(outstanding), "orange"], ["Paid", fmtCurrency(paid), "green"]]) : ""}${rows}`;
  }

  if (view.screen === "clients") return renderClients();
  if (view.screen === "detail") return renderInvoiceDetail(view.id);
}

function invoiceTotal(inv) { return (inv.lineItems || []).reduce((s, li) => s + li.qty * li.price, 0); }
function effectiveStatus(inv) {
  if (inv.status === "sent" && inv.dueDate < todayISO()) return "overdue";
  return inv.status;
}
function statusLabel(s) { return { draft: "Draft", sent: "Sent", paid: "Paid", overdue: "Overdue" }[s]; }

function renderClients() {
  setNav("Clients", { back: true, trailingHtml: `<span onclick="openClientForm()">＋</span>` });
  if (state.clients.length === 0) return emptyState("👥", "No Clients Yet", "Add a client so you can attach them to invoices.");
  return `<div class="list-section">` + state.clients.map(c => `
    <div class="list-row" onclick="openClientForm('${c.id}')">
      <div class="row-main">
        <div class="row-title">${escapeHtml(c.name)}</div>
        ${c.email ? `<div class="row-sub">${escapeHtml(c.email)}</div>` : ""}
      </div>
      <div class="delete-x" onclick="event.stopPropagation(); deleteClient('${c.id}')">✕</div>
    </div>`).join("") + `</div>`;
}
function deleteClient(id) {
  state.clients = state.clients.filter(c => c.id !== id);
  render();
}
function openClientForm(id) {
  const existing = id ? state.clients.find(c => c.id === id) : null;
  const draft = existing || { name: "", email: "", phone: "", address: "" };
  openModal(() => `
    <div class="nav-bar">
      <div class="nav-leading"><span onclick="closeModal()">Cancel</span></div>
      <div class="nav-title">${existing ? "Edit Client" : "New Client"}</div>
      <div class="nav-trailing"><span onclick="saveClientForm('${id || ""}')">Save</span></div>
    </div>
    <div class="form-group">
      <div class="form-row"><label>Name</label><input type="text" id="f_name" value="${escapeAttr(draft.name)}" /></div>
      <div class="form-row"><label>Email</label><input type="text" id="f_email" value="${escapeAttr(draft.email)}" /></div>
      <div class="form-row"><label>Phone</label><input type="text" id="f_phone" value="${escapeAttr(draft.phone)}" /></div>
      <div class="form-row"><textarea id="f_address" placeholder="Address">${escapeHtml(draft.address || "")}</textarea></div>
    </div>
  `);
}
function saveClientForm(id) {
  const name = document.getElementById("f_name").value.trim();
  if (!name) { alert("Name is required"); return; }
  const data = {
    name,
    email: document.getElementById("f_email").value,
    phone: document.getElementById("f_phone").value,
    address: document.getElementById("f_address").value
  };
  if (id) Object.assign(state.clients.find(c => c.id === id), data);
  else state.clients.push({ id: uid(), ...data });
  closeModal();
  render();
}

let invoiceDraftItems = [];
function openInvoiceForm(id) {
  const existing = id ? state.invoices.find(i => i.id === id) : null;
  const draft = existing
    ? { ...existing }
    : { number: `INV-${String(state.invoices.length + 1).padStart(3, "0")}`, clientId: state.clients[0]?.id || "", issueDate: todayISO(), dueDate: todayISO(14), status: "draft", notes: "" };
  invoiceDraftItems = existing ? existing.lineItems.map(li => ({ ...li })) : [{ id: uid(), description: "", qty: 1, price: 0 }];

  openModal(() => renderInvoiceFormBody(id, draft));
}

function renderInvoiceFormBody(id, draft) {
  const subtotal = invoiceDraftItems.reduce((s, li) => s + li.qty * li.price, 0);
  return `
    <div class="nav-bar">
      <div class="nav-leading"><span onclick="closeModal()">Cancel</span></div>
      <div class="nav-title">${id ? "Edit Invoice" : "New Invoice"}</div>
      <div class="nav-trailing"><span onclick="saveInvoiceForm('${id || ""}')">Save</span></div>
    </div>
    <div class="form-group">
      <div class="form-row"><label>Number</label><input type="text" id="f_number" value="${escapeAttr(draft.number)}" /></div>
      <div class="form-row"><label>Client</label>
        <select id="f_client">
          <option value="">None</option>
          ${state.clients.map(c => `<option value="${c.id}" ${c.id === draft.clientId ? "selected" : ""}>${escapeHtml(c.name)}</option>`).join("")}
        </select>
      </div>
      <div class="form-row"><label>Issue Date</label><input type="date" id="f_issue" value="${draft.issueDate}" /></div>
      <div class="form-row"><label>Due Date</label><input type="date" id="f_due" value="${draft.dueDate}" /></div>
      <div class="form-row"><label>Status</label>
        <select id="f_status">
          ${["draft", "sent", "paid", "overdue"].map(s => `<option value="${s}" ${s === draft.status ? "selected" : ""}>${statusLabel(s)}</option>`).join("")}
        </select>
      </div>
    </div>
    <div class="section-label">Line Items</div>
    <div class="form-group">
      ${invoiceDraftItems.map((li, idx) => `
        <div class="line-item-row">
          <input type="text" style="width:100%;border:none;outline:none;font-size:14px;" placeholder="Description" value="${escapeAttr(li.description)}" oninput="invoiceDraftItems[${idx}].description=this.value" />
          <div class="line-item-fields">
            <input type="number" step="0.01" value="${li.qty}" oninput="invoiceDraftItems[${idx}].qty=parseFloat(this.value)||0; refreshModal();" title="Qty" />
            <span>×</span>
            <input type="number" step="0.01" value="${li.price}" oninput="invoiceDraftItems[${idx}].price=parseFloat(this.value)||0; refreshModal();" title="Unit price" />
            <span style="width:70px;text-align:right;font-size:13px;color:var(--secondary)">${fmtCurrency(li.qty * li.price)}</span>
            <span class="li-remove" onclick="invoiceDraftItems.splice(${idx},1); refreshModal();">✕</span>
          </div>
        </div>
      `).join("")}
      <div class="form-row" style="justify-content:center;color:var(--accent);cursor:pointer;" onclick="invoiceDraftItems.push({id:uid(),description:'',qty:1,price:0}); refreshModal();">+ Add Line Item</div>
      <div class="form-row"><label>Subtotal</label><strong>${fmtCurrency(subtotal)}</strong></div>
    </div>
    <div class="form-group">
      <div class="form-row"><textarea id="f_notes" placeholder="Notes">${escapeHtml(draft.notes || "")}</textarea></div>
    </div>
  `;
}
function saveInvoiceForm(id) {
  const number = document.getElementById("f_number").value.trim();
  if (!number) { alert("Invoice number is required"); return; }
  const data = {
    number,
    clientId: document.getElementById("f_client").value,
    issueDate: document.getElementById("f_issue").value,
    dueDate: document.getElementById("f_due").value,
    status: document.getElementById("f_status").value,
    notes: document.getElementById("f_notes").value,
    lineItems: invoiceDraftItems.filter(li => li.description || li.qty || li.price)
  };
  if (id) {
    const inv = state.invoices.find(i => i.id === id);
    Object.assign(inv, data);
    if (data.status === "paid" && !inv.paidDate) inv.paidDate = todayISO();
    if (data.status !== "paid") inv.paidDate = null;
  } else {
    state.invoices.push({ id: uid(), paidDate: data.status === "paid" ? todayISO() : null, ...data });
  }
  closeModal();
  render();
}

function renderInvoiceDetail(id) {
  const inv = state.invoices.find(i => i.id === id);
  if (!inv) { pop(); return ""; }
  const client = state.clients.find(c => c.id === inv.clientId);
  const status = effectiveStatus(inv);
  setNav("Invoice", { back: true, trailingHtml: `<span onclick="openInvoiceForm('${inv.id}')">Edit</span>` });

  return `
    <div class="list-section" style="padding:14px;">
      <div style="display:flex;justify-content:space-between;align-items:flex-start;">
        <div>
          <div style="font-size:18px;font-weight:800;">#${escapeHtml(inv.number)}</div>
          <div style="color:var(--secondary);font-size:13px;">${escapeHtml(client ? client.name : "No client assigned")}</div>
        </div>
        <div class="badge ${status}">${statusLabel(status)}</div>
      </div>
      <hr style="border:none;border-top:1px solid var(--sep);margin:10px 0;" />
      <div class="row-sub2">Issued ${fmtDate(inv.issueDate)} · Due ${fmtDate(inv.dueDate)}</div>
      ${inv.paidDate ? `<div class="row-sub2" style="color:var(--green)">Paid ${fmtDate(inv.paidDate)}</div>` : ""}
    </div>

    <div class="section-label">Line Items</div>
    <div class="list-section">
      ${inv.lineItems.map(li => `
        <div class="list-row" style="cursor:default;">
          <div class="row-main">
            <div class="row-title">${escapeHtml(li.description || "Item")}</div>
            <div class="row-sub2">${li.qty} × ${fmtCurrency(li.price)}</div>
          </div>
          <div class="row-amount">${fmtCurrency(li.qty * li.price)}</div>
        </div>`).join("")}
      <div class="list-row" style="cursor:default;"><div class="row-main"><strong>Total</strong></div><strong>${fmtCurrency(invoiceTotal(inv))}</strong></div>
    </div>

    ${inv.notes ? `<div class="section-label">Notes</div><div class="list-section" style="padding:12px 14px;font-size:14px;">${escapeHtml(inv.notes)}</div>` : ""}

    <div class="section-label">Payment Status</div>
    <div class="status-segment">
      ${["draft", "sent", "paid", "overdue"].map(s => `<button class="${inv.status === s ? "active" : ""}" onclick="setInvoiceStatus('${inv.id}','${s}')">${statusLabel(s)}</button>`).join("")}
    </div>

    <button class="btn btn-primary" onclick="shareInvoicePDF('${inv.id}')">📤 Send / Share Invoice PDF</button>
  `;
}
function setInvoiceStatus(id, status) {
  const inv = state.invoices.find(i => i.id === id);
  inv.status = status;
  if (status === "paid") inv.paidDate = inv.paidDate || todayISO();
  else inv.paidDate = null;
  render();
}
function shareInvoicePDF(id) {
  const inv = state.invoices.find(i => i.id === id);
  const client = state.clients.find(c => c.id === inv.clientId);
  if (inv.status === "draft") inv.status = "sent";
  saveState();

  const win = window.open("", "_blank", "width=650,height=800");
  win.document.write(`
    <html><head><title>Invoice ${inv.number}</title>
    <style>
      body{font-family:-apple-system,Helvetica,Arial,sans-serif;padding:40px;color:#111;}
      h1{font-size:22px;margin-bottom:0;} .muted{color:#666;font-size:13px;}
      table{width:100%;border-collapse:collapse;margin-top:20px;}
      td,th{padding:8px 4px;border-bottom:1px solid #eee;text-align:left;font-size:14px;}
      .total{font-weight:800;font-size:16px;}
      hr{border:none;border-top:1px solid #ddd;margin:20px 0;}
    </style></head><body>
    <h1>${escapeHtml(state.settings.businessName || "Invoice")}</h1>
    <div class="muted">${escapeHtml(state.settings.businessEmail || "")}</div>
    <hr/>
    <div><strong>INVOICE #${escapeHtml(inv.number)}</strong></div>
    <div class="muted">Issued: ${fmtDate(inv.issueDate)} &nbsp;·&nbsp; Due: ${fmtDate(inv.dueDate)} &nbsp;·&nbsp; Status: ${statusLabel(effectiveStatus(inv))}</div>
    <hr/>
    <div><strong>Bill To</strong></div>
    <div>${escapeHtml(client ? client.name : "—")}</div>
    <div class="muted">${escapeHtml(client ? client.email : "")}</div>
    <table>
      <tr><th>Description</th><th>Qty</th><th>Unit Price</th><th>Total</th></tr>
      ${inv.lineItems.map(li => `<tr><td>${escapeHtml(li.description)}</td><td>${li.qty}</td><td>${fmtCurrency(li.price)}</td><td>${fmtCurrency(li.qty * li.price)}</td></tr>`).join("")}
    </table>
    <hr/>
    <div class="total">Total: ${fmtCurrency(invoiceTotal(inv))}</div>
    ${inv.notes ? `<hr/><div><strong>Notes</strong></div><div>${escapeHtml(inv.notes)}</div>` : ""}
    <script>window.onload = () => window.print();<\/script>
    </body></html>
  `);
  win.document.close();
  render();
}

/* ===================== TIME ===================== */
function renderTime(view) {
  if (view.screen === "root") {
    setNav("Time");
    const running = state.timeEntries.find(t => !t.endTime);
    const recent = [...state.timeEntries].sort((a, b) => b.startTime.localeCompare(a.startTime)).slice(0, 5);

    return `
      <div class="timer-card">
        ${running ? runningTimerHtml(running) : startTimerHtml()}
      </div>
      ${recent.length ? `<div class="section-label">Recent</div><div class="list-section">${recent.map(timeEntryRow).join("")}</div>` : ""}
      <div class="list-section">
        <div class="list-row" onclick="push('allEntries')"><div class="row-main">📋 &nbsp; All Time Entries</div></div>
        <div class="list-row" onclick="push('people')"><div class="row-main">👥 &nbsp; People</div></div>
      </div>
    `;
  }
  if (view.screen === "allEntries") return renderAllEntries();
  if (view.screen === "people") return renderPeople();
}

function startTimerHtml() {
  return `
    <div class="timer-heading">Start a Timer</div>
    ${state.people.length === 0 ? `<div style="color:var(--secondary);font-size:13px;">Add a person first to start logging hours.</div>` : `
      <select id="timer_person" style="width:100%;padding:8px;border-radius:8px;border:1px solid var(--sep);margin-bottom:8px;">
        <option value="">Select person</option>
        ${state.people.map(p => `<option value="${p.id}">${escapeHtml(p.name)}</option>`).join("")}
      </select>
      <input type="text" id="timer_project" placeholder="Project / Gig name" style="width:100%;padding:8px;border-radius:8px;border:1px solid var(--sep);margin-bottom:10px;" />
      <button class="btn btn-primary" style="margin:0;width:100%;" onclick="startTimer()">▶ Start Timer</button>
    `}
  `;
}
function runningTimerHtml(entry) {
  const person = state.people.find(p => p.id === entry.personId);
  setTimeout(() => {
    const el = document.getElementById("timerElapsed");
    if (el) el.textContent = fmtDuration((Date.now() - new Date(entry.startTime).getTime()) / 1000);
  }, 0);
  timerInterval = setInterval(() => {
    const el = document.getElementById("timerElapsed");
    if (el) el.textContent = fmtDuration((Date.now() - new Date(entry.startTime).getTime()) / 1000);
  }, 1000);
  return `
    <div><span class="timer-running-dot"></span><strong>Timer Running</strong></div>
    <div style="margin-top:8px;font-weight:600;">${escapeHtml(person ? person.name : "Unknown")}</div>
    ${entry.project ? `<div style="color:var(--secondary);font-size:13px;">${escapeHtml(entry.project)}</div>` : ""}
    <div class="timer-display" id="timerElapsed">0s</div>
    <button class="btn btn-danger" style="margin:0;width:100%;" onclick="stopTimer('${entry.id}')">■ Stop Timer</button>
  `;
}
function startTimer() {
  const personId = document.getElementById("timer_person").value;
  if (!personId) return;
  const project = document.getElementById("timer_project").value;
  state.timeEntries.push({ id: uid(), personId, project, startTime: new Date().toISOString(), endTime: null, notes: "" });
  render();
}
function stopTimer(id) {
  const entry = state.timeEntries.find(t => t.id === id);
  entry.endTime = new Date().toISOString();
  render();
}
function timeEntryRow(entry) {
  const person = state.people.find(p => p.id === entry.personId);
  const running = !entry.endTime;
  const durationSec = ((entry.endTime ? new Date(entry.endTime) : new Date()) - new Date(entry.startTime)) / 1000;
  return `
    <div class="list-row" onclick="openTimeEntryForm('${entry.id}')">
      <div class="row-main">
        <div class="row-title">${escapeHtml(person ? person.name : "Unassigned")}</div>
        ${entry.project ? `<div class="row-sub">${escapeHtml(entry.project)}</div>` : ""}
        <div class="row-sub2">${fmtDate(entry.startTime.slice(0, 10))}</div>
      </div>
      <div class="row-trail">${running ? `<span style="color:var(--red);font-weight:700;font-size:12px;">● Running</span>` : `<div class="row-amount">${fmtHours(durationSec)}</div>`}</div>
    </div>
  `;
}
function renderAllEntries() {
  setNav("All Time Entries", { back: true, trailingHtml: `<span onclick="openTimeEntryForm()">＋</span>` });
  const entries = [...state.timeEntries].sort((a, b) => b.startTime.localeCompare(a.startTime));
  const totalHours = entries.reduce((s, e) => s + ((e.endTime ? new Date(e.endTime) : new Date()) - new Date(e.startTime)) / 3600000, 0);
  if (entries.length === 0) return emptyState("⏱️", "No Time Logged Yet", "Start the timer or log hours manually.");
  return `
    ${statRow([["Total Hours", totalHours.toFixed(1)], ["Entries", String(entries.length)]])}
    <div class="list-section">${entries.map(timeEntryRow).join("")}</div>
  `;
}
function openTimeEntryForm(id) {
  const existing = id ? state.timeEntries.find(t => t.id === id) : null;
  const draft = existing
    ? { ...existing, isOngoing: !existing.endTime }
    : { personId: state.people[0]?.id || "", project: "", startTime: new Date().toISOString(), endTime: new Date().toISOString(), isOngoing: false, notes: "" };

  openModal(() => `
    <div class="nav-bar">
      <div class="nav-leading"><span onclick="closeModal()">Cancel</span></div>
      <div class="nav-title">${existing ? "Edit Time Entry" : "Log Hours"}</div>
      <div class="nav-trailing"><span onclick="saveTimeEntryForm('${id || ""}')">Save</span></div>
    </div>
    <div class="form-group">
      <div class="form-row"><label>Person</label>
        <select id="f_person">
          <option value="">Select person</option>
          ${state.people.map(p => `<option value="${p.id}" ${p.id === draft.personId ? "selected" : ""}>${escapeHtml(p.name)}</option>`).join("")}
        </select>
      </div>
      <div class="form-row"><label>Project</label><input type="text" id="f_project" value="${escapeAttr(draft.project)}" /></div>
    </div>
    <div class="form-group">
      <div class="form-row"><label>Start</label><input type="datetime-local" id="f_start" value="${toLocalInput(draft.startTime)}" /></div>
      <div class="form-row"><label>Still running</label><input type="checkbox" id="f_ongoing" ${draft.isOngoing ? "checked" : ""} onchange="document.getElementById('f_end_row').style.display=this.checked?'none':'flex'" /></div>
      <div class="form-row" id="f_end_row" style="display:${draft.isOngoing ? "none" : "flex"};"><label>End</label><input type="datetime-local" id="f_end" value="${toLocalInput(draft.endTime)}" /></div>
    </div>
    <div class="form-group">
      <div class="form-row"><textarea id="f_notes" placeholder="Notes">${escapeHtml(draft.notes || "")}</textarea></div>
    </div>
    ${existing ? `<button class="btn btn-danger" onclick="deleteTimeEntry('${existing.id}'); closeModal();">Delete Entry</button>` : ""}
  `);
}
function toLocalInput(iso) {
  const d = new Date(iso);
  const pad = n => String(n).padStart(2, "0");
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
}
function saveTimeEntryForm(id) {
  const personId = document.getElementById("f_person").value;
  if (!personId) { alert("Please select a person"); return; }
  const isOngoing = document.getElementById("f_ongoing").checked;
  const data = {
    personId,
    project: document.getElementById("f_project").value,
    startTime: new Date(document.getElementById("f_start").value).toISOString(),
    endTime: isOngoing ? null : new Date(document.getElementById("f_end").value).toISOString(),
    notes: document.getElementById("f_notes").value
  };
  if (id) Object.assign(state.timeEntries.find(t => t.id === id), data);
  else state.timeEntries.push({ id: uid(), ...data });
  closeModal();
  render();
}
function deleteTimeEntry(id) {
  state.timeEntries = state.timeEntries.filter(t => t.id !== id);
  render();
}

function renderPeople() {
  setNav("People", { back: true, trailingHtml: `<span onclick="openPersonForm()">＋</span>` });
  if (state.people.length === 0) return emptyState("👥", "No People Yet", "Add band members or crew so they can log hours.");
  return `<div class="list-section">` + state.people.map(p => `
    <div class="list-row" onclick="openPersonForm('${p.id}')">
      <div class="row-main">
        <div class="row-title">${escapeHtml(p.name)}</div>
        ${p.role ? `<div class="row-sub">${escapeHtml(p.role)}</div>` : ""}
      </div>
      ${p.hourlyRate ? `<div class="row-sub">${fmtCurrency(p.hourlyRate)}/hr</div>` : ""}
      <div class="delete-x" onclick="event.stopPropagation(); deletePerson('${p.id}')">✕</div>
    </div>`).join("") + `</div>`;
}
function deletePerson(id) {
  state.people = state.people.filter(p => p.id !== id);
  render();
}
function openPersonForm(id) {
  const existing = id ? state.people.find(p => p.id === id) : null;
  const draft = existing || { name: "", role: "", hourlyRate: 0 };
  openModal(() => `
    <div class="nav-bar">
      <div class="nav-leading"><span onclick="closeModal()">Cancel</span></div>
      <div class="nav-title">${existing ? "Edit Person" : "New Person"}</div>
      <div class="nav-trailing"><span onclick="savePersonForm('${id || ""}')">Save</span></div>
    </div>
    <div class="form-group">
      <div class="form-row"><label>Name</label><input type="text" id="f_name" value="${escapeAttr(draft.name)}" /></div>
      <div class="form-row"><label>Role</label><input type="text" id="f_role" value="${escapeAttr(draft.role)}" placeholder="Guitarist, Sound Tech…" /></div>
      <div class="form-row"><label>Hourly Rate</label><input type="number" step="0.01" id="f_rate" value="${draft.hourlyRate}" /></div>
    </div>
  `);
}
function savePersonForm(id) {
  const name = document.getElementById("f_name").value.trim();
  if (!name) { alert("Name is required"); return; }
  const data = { name, role: document.getElementById("f_role").value, hourlyRate: parseFloat(document.getElementById("f_rate").value) || 0 };
  if (id) Object.assign(state.people.find(p => p.id === id), data);
  else state.people.push({ id: uid(), ...data });
  closeModal();
  render();
}

/* ===================== DRIVING ===================== */
function renderDriving(view) {
  setNav("Driving", { trailingHtml: `<span onclick="openTripForm()">＋</span>` });
  const trips = [...state.trips].sort((a, b) => b.date.localeCompare(a.date));
  const totalMiles = trips.reduce((s, t) => s + t.miles, 0);
  const totalCost = trips.reduce((s, t) => s + t.miles * t.rate, 0);

  let rows;
  if (trips.length === 0) {
    rows = emptyState("🚗", "No Trips Yet", "Log a trip to calculate driving costs using your mileage rate.");
  } else {
    rows = `<div class="list-section">` + trips.map(t => `
      <div class="list-row" onclick="openTripForm('${t.id}')">
        <div class="row-main">
          <div class="row-title">${escapeHtml(t.start || t.end ? `${t.start} → ${t.end}` : "Trip")}</div>
          ${t.purpose ? `<div class="row-sub">${escapeHtml(t.purpose)}</div>` : ""}
          <div class="row-sub2">${fmtDate(t.date)}</div>
        </div>
        <div class="row-trail">
          <div class="row-amount">${fmtCurrency(t.miles * t.rate)}</div>
          <div class="row-sub2">${t.miles} mi</div>
        </div>
        <div class="delete-x" onclick="event.stopPropagation(); deleteTrip('${t.id}')">✕</div>
      </div>`).join("") + `</div>`;
  }
  return `${trips.length ? statRow([["Total Miles", totalMiles.toFixed(1)], ["Total Cost", fmtCurrency(totalCost), "green"]]) : ""}${rows}`;
}
function deleteTrip(id) {
  state.trips = state.trips.filter(t => t.id !== id);
  render();
}
function openTripForm(id) {
  const existing = id ? state.trips.find(t => t.id === id) : null;
  const draft = existing || { date: todayISO(), start: "", end: "", miles: 0, rate: state.settings.mileageRate, purpose: "", notes: "" };
  openModal(() => renderTripFormBody(id, draft));
}
function renderTripFormBody(id, draft) {
  return `
    <div class="nav-bar">
      <div class="nav-leading"><span onclick="closeModal()">Cancel</span></div>
      <div class="nav-title">${id ? "Edit Trip" : "New Trip"}</div>
      <div class="nav-trailing"><span onclick="saveTripForm('${id || ""}')">Save</span></div>
    </div>
    <div class="form-group">
      <div class="form-row"><label>Start Location</label><input type="text" id="f_start" value="${escapeAttr(draft.start)}" /></div>
      <div class="form-row"><label>End Location</label><input type="text" id="f_end" value="${escapeAttr(draft.end)}" /></div>
      <div class="form-row"><label>Date</label><input type="date" id="f_date" value="${draft.date}" /></div>
      <div class="form-row"><label>Purpose</label><input type="text" id="f_purpose" value="${escapeAttr(draft.purpose)}" placeholder="Gig at The Venue" /></div>
    </div>
    <div class="form-group">
      <div class="form-row"><label>Miles Driven</label><input type="number" step="0.1" id="f_miles" value="${draft.miles}" oninput="refreshTripCost()" /></div>
      <div class="form-row"><label>Rate / Mile</label><input type="number" step="0.01" id="f_rate" value="${draft.rate}" oninput="refreshTripCost()" /></div>
      <div class="form-row"><label>Total Cost</label><strong id="f_cost">${fmtCurrency(draft.miles * draft.rate)}</strong></div>
    </div>
    <div class="form-group">
      <div class="form-row"><textarea id="f_notes" placeholder="Notes">${escapeHtml(draft.notes || "")}</textarea></div>
    </div>
    ${id ? `<button class="btn btn-danger" onclick="deleteTrip('${id}'); closeModal();">Delete Trip</button>` : ""}
  `;
}
function refreshTripCost() {
  const miles = parseFloat(document.getElementById("f_miles").value) || 0;
  const rate = parseFloat(document.getElementById("f_rate").value) || 0;
  document.getElementById("f_cost").textContent = fmtCurrency(miles * rate);
}
function saveTripForm(id) {
  const data = {
    start: document.getElementById("f_start").value,
    end: document.getElementById("f_end").value,
    date: document.getElementById("f_date").value || todayISO(),
    purpose: document.getElementById("f_purpose").value,
    miles: parseFloat(document.getElementById("f_miles").value) || 0,
    rate: parseFloat(document.getElementById("f_rate").value) || 0,
    notes: document.getElementById("f_notes").value
  };
  if (id) Object.assign(state.trips.find(t => t.id === id), data);
  else state.trips.push({ id: uid(), ...data });
  closeModal();
  render();
}

/* ===================== SETTINGS ===================== */
function renderSettings(view) {
  if (view.screen === "root") {
    setNav("Settings");
    return `
      <div class="section-label">Business Info</div>
      <div class="form-group">
        <div class="form-row"><label>Name</label><input type="text" value="${escapeAttr(state.settings.businessName)}" oninput="state.settings.businessName=this.value; saveState();" /></div>
        <div class="form-row"><label>Email</label><input type="text" value="${escapeAttr(state.settings.businessEmail)}" oninput="state.settings.businessEmail=this.value; saveState();" /></div>
      </div>
      <div class="section-label">Currency</div>
      <div class="form-group">
        <div class="form-row"><label>Currency</label>
          <select onchange="state.settings.currency=this.value; saveState(); render();">
            ${["USD", "EUR", "GBP", "CAD", "AUD"].map(c => `<option ${c === state.settings.currency ? "selected" : ""}>${c}</option>`).join("")}
          </select>
        </div>
      </div>
      <div class="section-label">Driving</div>
      <div class="form-group">
        <div class="form-row"><label>Default Mileage Rate</label><input type="number" step="0.01" value="${state.settings.mileageRate}" oninput="state.settings.mileageRate=parseFloat(this.value)||0; saveState();" /></div>
      </div>
      <div class="form-group">
        <div class="list-row" onclick="push('people')"><div class="row-main">👥 &nbsp; People</div></div>
        <div class="list-row" onclick="push('clients')"><div class="row-main">💼 &nbsp; Clients</div></div>
      </div>
      <div class="form-hint" style="padding:0 16px 16px;">GigTrack — Receipts, invoices, timesheets, and driving costs for people in the music industry.</div>
      <button class="btn btn-secondary" onclick="resetDemo()">Reset Demo Data</button>
    `;
  }
  if (view.screen === "people") return renderPeople();
  if (view.screen === "clients") return renderClients();
}

/* ===================== Shared helpers ===================== */
function statRow(items) {
  return `<div class="stat-row">${items.map(([title, value, color]) => `
    <div class="stat-card"><div class="stat-title">${title}</div><div class="stat-value" style="${color ? `color:var(--${color})` : ""}">${value}</div></div>
  `).join("")}</div>`;
}
function emptyState(emoji, title, msg) {
  return `<div class="empty-state"><div class="emoji">${emoji}</div><div class="title">${title}</div><div class="msg">${msg}</div></div>`;
}
function escapeHtml(str) {
  return String(str || "").replace(/[&<>"']/g, s => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[s]));
}
function escapeAttr(str) { return escapeHtml(str); }

render();
