// ═══════════════════════════════════════════════════════
//  FixHub - Track Page Logic
// ═══════════════════════════════════════════════════════

// 🔧 إعدادات Supabase
const SUPABASE_URL = 'https://skhssmwzdrubgkoykavo.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNraHNzbXd6ZHJ1Ymdrb3lrYXZvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE1MTI2NDksImV4cCI6MjEwNzA4ODY0OX0.z83lKNKmG15EnlyyWweAVHOtufbYfAoAM4xprbk3za0';// ⚠️ استبدل الـ anon-key بالـ key الفعلي من Supabase Dashboard → Settings → API

// ─── Status → Label mapping ───
const STATUS_LABELS = {
  received: 'تم الاستلام',
  inProgress: 'قيد الإصلاح',
  waitingParts: 'في انتظار قطع الغيار',
  ready: 'جاهز للتسليم',
  delivered: 'تم التسليم',
  rejected: 'مرفوض',
};

const STATUS_COLORS = {
  received: '#3B82F6',
  inProgress: '#F59E0B',
  waitingParts: '#8B5CF6',
  ready: '#10B981',
  delivered: '#059669',
  rejected: '#EF4444',
};

// ─── Steps (الخط الزمني) ───
const STEPS = [
  { key: 'received', label: 'تم الاستلام', icon: '📥' },
  { key: 'inProgress', label: 'قيد الإصلاح', icon: '🔧' },
  { key: 'waitingParts', label: 'انتظار قطع', icon: '⏳' },
  { key: 'ready', label: 'جاهز للتسليم', icon: '✅' },
  { key: 'delivered', label: 'تم التسليم', icon: '📦' },
];

// ─── Elements ───
const phoneInput = document.getElementById('phoneInput');
const receiptInput = document.getElementById('receiptInput');
const searchBtn = document.getElementById('searchBtn');
const resultsContainer = document.getElementById('results');
const loadingEl = document.getElementById('loading');
const errorEl = document.getElementById('errorMessage');
const errorTextEl = document.getElementById('errorText');

// ═══════════════════════════════════════════════════════
//  Search Handler
// ═══════════════════════════════════════════════════════
searchBtn.addEventListener('click', handleSearch);

// Enter key
[phoneInput, receiptInput].forEach((input) => {
  input.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') handleSearch();
  });
});

async function handleSearch() {
  const phone = phoneInput.value.trim();
  const receiptNumber = receiptInput.value.trim();

  // Validation
  if (!phone && !receiptNumber) {
    showError('من فضلك أدخل رقم التليفون أو رقم الإيصال');
    return;
  }

  hideError();
  resultsContainer.classList.add('hidden');
  loadingEl.classList.remove('hidden');

  try {
    const data = await fetchReceipts(phone, receiptNumber);

    loadingEl.classList.add('hidden');

    if (!data || data.length === 0) {
      showEmptyState(phone || receiptNumber);
      return;
    }

    renderResults(data);
  } catch (err) {
    loadingEl.classList.add('hidden');
    showError('حدث خطأ في البحث. حاول مرة أخرى.');
    console.error(err);
  }
}

// ═══════════════════════════════════════════════════════
//  Fetch from Supabase (RPC: track_receipts)
// ═══════════════════════════════════════════════════════
async function fetchReceipts(phone, receiptNumber) {
  const response = await fetch(
    `${SUPABASE_URL}/rest/v1/rpc/track_receipts`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      },
      body: JSON.stringify({
        p_phone: phone || null,
        p_receipt_number: receiptNumber || null,
      }),
    }
  );

  if (!response.ok) {
    const err = await response.text();
    throw new Error(err);
  }

  return await response.json();
}

// ═══════════════════════════════════════════════════════
//  Render Results
// ═══════════════════════════════════════════════════════
function renderResults(receipts) {
  resultsContainer.innerHTML = '';
  resultsContainer.classList.remove('hidden');

  receipts.forEach((receipt) => {
    const card = createReceiptCard(receipt);
    resultsContainer.appendChild(card);
  });
}

function createReceiptCard(receipt) {
  const card = document.createElement('div');
  card.className = 'receipt-card';

  const deviceName =
    [receipt.device_brand, receipt.device_model]
      .filter(Boolean)
      .join(' ') || 'جهاز غير معروف';

  const statusLabel = STATUS_LABELS[receipt.status] || receipt.status;
  const statusColor = STATUS_COLORS[receipt.status] || '#6B7280';

  // ─── Header ───
  const header = document.createElement('div');
  header.className = 'receipt-header';
  header.innerHTML = `
    <div>
      <div class="receipt-number">${receipt.receipt_number}</div>
      <div class="receipt-device">${deviceName}</div>
    </div>
    <div class="receipt-status-badge" style="background: ${statusColor}20; color: ${statusColor};">
      ${statusLabel}
    </div>
  `;
  card.appendChild(header);

  // ─── Timeline ───
  const timeline = createTimeline(receipt.status);
  card.appendChild(timeline);

  // ─── Info Grid ───
  const total = receipt.final_cost || receipt.estimated_cost || 0;
  const deposit = receipt.deposit || 0;
  const remaining = Math.max(0, total - deposit);

  const infoGrid = document.createElement('div');
  infoGrid.className = 'info-grid';
  infoGrid.innerHTML = `
    <div class="info-item">
      <span class="info-label">الإجمالي</span>
      <span class="info-value">${formatCurrency(total)}</span>
    </div>
    <div class="info-item">
      <span class="info-label">العربون</span>
      <span class="info-value">${formatCurrency(deposit)}</span>
    </div>
    <div class="info-item">
      <span class="info-label">المتبقي</span>
      <span class="info-value ${remaining > 0 ? 'remaining' : ''}">
        ${formatCurrency(remaining)}
      </span>
    </div>
    <div class="info-item">
      <span class="info-label">العميل</span>
      <span class="info-value">${receipt.customer_name || '—'}</span>
    </div>
  `;
  card.appendChild(infoGrid);

  return card;
}

// ═══════════════════════════════════════════════════════
//  Timeline
// ═══════════════════════════════════════════════════════
function createTimeline(currentStatus) {
  const timeline = document.createElement('div');
  timeline.className = 'timeline';

  const currentIndex = STEPS.findIndex((s) => s.key === currentStatus);

  STEPS.forEach((step, index) => {
    const stepEl = document.createElement('div');
    stepEl.className = 'timeline-step';

    if (index < currentIndex) {
      stepEl.classList.add('completed');
    } else if (index === currentIndex) {
      stepEl.classList.add('active');
    }

    stepEl.innerHTML = `
      <div class="step-icon">
        ${index < currentIndex ? '✓' : index === currentIndex ? step.icon : index + 1}
      </div>
      <div class="step-content">
        <div class="step-title">${index + 1}. ${step.label}</div>
      </div>
    `;

    timeline.appendChild(stepEl);
  });

  return timeline;
}

// ═══════════════════════════════════════════════════════
//  Empty State
// ═══════════════════════════════════════════════════════
function showEmptyState(query) {
  resultsContainer.innerHTML = `
    <div class="empty-state">
      <div class="empty-icon">🎉</div>
      <div class="empty-title">كل أجهزتك تم تسليمها بنجاح</div>
      <div class="empty-description">
        شكراً لثقتك بنا.<br>
        لو عندك جهاز جديد، تواصل مع الورشة.
      </div>
    </div>
  `;
  resultsContainer.classList.remove('hidden');
}

// ═══════════════════════════════════════════════════════
//  Error
// ═══════════════════════════════════════════════════════
function showError(message) {
  errorTextEl.textContent = message;
  errorEl.classList.remove('hidden');
}

function hideError() {
  errorEl.classList.add('hidden');
}

// ═══════════════════════════════════════════════════════
//  Helpers
// ═══════════════════════════════════════════════════════
function formatCurrency(amount) {
  if (!amount || amount === 0) return '0 ج.م';
  return new Intl.NumberFormat('ar-EG', {
    maximumFractionDigits: 0,
  }).format(amount) + ' ج.م';
}