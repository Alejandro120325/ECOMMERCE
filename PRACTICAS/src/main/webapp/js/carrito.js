/* ============================================================
   FOLIO - Carrito de Compras (Actualizado para Botones Estáticos)
   ============================================================ */
(function () {
    'use strict';

    const KEY_ANON = 'folio-cart';
    const KEY_USER = 'folio-user';

    function getUserEmail() { return localStorage.getItem(KEY_USER) || null; }
    function getCartKey() { const email = getUserEmail(); return email ? 'folio-cart-' + email : KEY_ANON; }
    function loadCart() { try { const raw = localStorage.getItem(getCartKey()); return raw ? JSON.parse(raw) : []; } catch (e) { return []; } }
    function saveCart(items) { localStorage.setItem(getCartKey(), JSON.stringify(items)); renderBadge(); }

    function addItem(book) {
        const items = loadCart();
        const existing = items.find(i => i.id === book.id);
        if (existing) { existing.qty += 1; } else { items.push({ ...book, qty: 1 }); }
        saveCart(items);
        renderPanel();
        pulseBadge();
        showToast('"' + book.titulo + '" añadido al carrito');
    }

    function removeItem(id) {
        const items = loadCart().filter(i => i.id !== id);
        saveCart(items);
        renderPanel();
    }

    function changeQty(id, delta) {
        const items = loadCart();
        const item = items.find(i => i.id === id);
        if (!item) return;
        item.qty = Math.max(1, item.qty + delta);
        saveCart(items);
        renderPanel();
    }

    function clearCart() { saveCart([]); renderPanel(); }
    function total() { return loadCart().reduce((sum, i) => sum + i.precio * i.qty, 0); }
    function count() { return loadCart().reduce((sum, i) => sum + i.qty, 0); }

    function setUser(email) {
        if (!email) return;
        const prev = localStorage.getItem(KEY_USER);
        const anon = JSON.parse(localStorage.getItem(KEY_ANON) || '[]');
        localStorage.setItem(KEY_USER, email);
        const userKey = 'folio-cart-' + email;
        const existingUserCart = JSON.parse(localStorage.getItem(userKey) || '[]');
        const merged = [...existingUserCart];
        anon.forEach(a => {
            const e = merged.find(m => m.id === a.id);
            if (e) e.qty += a.qty; else merged.push(a);
        });
        localStorage.setItem(userKey, JSON.stringify(merged));
        if (prev !== email) localStorage.removeItem(KEY_ANON);
        renderBadge();
        renderPanel();
    }

    function logout() { localStorage.removeItem(KEY_USER); renderBadge(); renderPanel(); }

    function renderBadge() {
        const badge = document.querySelector('.carrito-badge');
        if (!badge) return;
        const c = count();
        badge.textContent = c;
        badge.classList.toggle('visible', c > 0);
    }

    function pulseBadge() {
        const badge = document.querySelector('.carrito-badge');
        if (!badge) return;
        badge.classList.remove('pulse');
        void badge.offsetWidth;
        badge.classList.add('pulse');
    }

    function renderPanel() {
        const panel = document.getElementById('carrito-panel');
        if (!panel) return;
        const itemsEl = panel.querySelector('.carrito-items');
        const totalEl = panel.querySelector('.total-valor');
        const userEl = panel.querySelector('.carrito-usuario');
        const items = loadCart();

        if (items.length === 0) {
            itemsEl.innerHTML = '<div class="carrito-vacio"><i class="fas fa-book-open"></i><p><strong>Tu carrito está vacío</strong></p><p>Explora nuestro catálogo y añade tus próximas lecturas.</p></div>';
        } else {
            itemsEl.innerHTML = items.map(it => '' +
                '<div class="carrito-item" data-id="' + escapeAttr(it.id) + '">' +
                '<img src="' + escapeAttr(it.imagen) + '" alt="">' +
                '<div class="info"><h5>' + escapeHtml(it.titulo) + '</h5><p class="autor">' + escapeHtml(it.autor) + '</p><span class="precio-item">$ ' + (it.precio * it.qty).toFixed(2) + '</span><div class="qty"><button data-action="decr" aria-label="Disminuir">−</button><span>' + it.qty + '</span><button data-action="incr" aria-label="Aumentar">+</button></div></div>' +
                '<button class="btn-eliminar" data-action="rm" aria-label="Eliminar"><i class="fas fa-trash"></i></button></div>'
            ).join('');
        }

        totalEl.textContent = '$ ' + total().toFixed(2);
        const email = getUserEmail();
        userEl.textContent = email ? 'Cuenta: ' + email : 'Invitado · regístrate para guardar tu carrito';
    }

    function showToast(msg) {
        let toast = document.getElementById('folio-toast');
        if (!toast) {
            toast = document.createElement('div');
            toast.id = 'folio-toast';
            toast.className = 'toast';
            toast.innerHTML = '<i class="fas fa-check-circle"></i><span></span>';
            document.body.appendChild(toast);
        }
        toast.querySelector('span').textContent = msg;
        toast.classList.add('visible');
        clearTimeout(toast._t);
        toast._t = setTimeout(() => toast.classList.remove('visible'), 2400);
    }

    function abrirPanel() { document.getElementById('carrito-panel').classList.add('abierto'); document.getElementById('carrito-overlay').classList.add('abierto'); renderPanel(); }
    function cerrarPanel() { document.getElementById('carrito-panel').classList.remove('abierto'); document.getElementById('carrito-overlay').classList.remove('abierto'); }

    function ensureDrawer() {
        if (document.getElementById('carrito-panel')) return;
        const overlay = document.createElement('div');
        overlay.id = 'carrito-overlay'; overlay.className = 'carrito-overlay';
        document.body.appendChild(overlay);

        const panel = document.createElement('aside');
        panel.id = 'carrito-panel'; panel.className = 'carrito-panel';
        panel.innerHTML = '<div class="carrito-header"><div><h3><i class="fas fa-shopping-basket"></i> Tu carrito</h3><div class="carrito-usuario"></div></div><button class="btn-cerrar-carrito" aria-label="Cerrar"><i class="fas fa-times"></i></button></div><div class="carrito-items"></div><div class="carrito-footer"><div class="carrito-total"><span>Total:</span><span class="total-valor">$ 0.00</span></div><button class="btn-comprar"><i class="fas fa-credit-card"></i> Finalizar compra</button><button class="btn-vaciar">Vaciar carrito</button></div>';
        document.body.appendChild(panel);

        overlay.addEventListener('click', cerrarPanel);
        panel.querySelector('.btn-cerrar-carrito').addEventListener('click', cerrarPanel);
        panel.querySelector('.btn-vaciar').addEventListener('click', () => { if (confirm('¿Vaciar todo el carrito?')) clearCart(); });
        panel.querySelector('.btn-comprar').addEventListener('click', () => {
            const items = loadCart();
            if (items.length === 0) { showToast('Tu carrito está vacío'); return; }
            const email = getUserEmail();
            if (!email) {
                if (confirm('Para comprar necesitas una cuenta. ¿Ir al registro?')) { window.location.href = 'registro.jsp'; }
                return;
            }
            abrirPago();
        });

        panel.querySelector('.carrito-items').addEventListener('click', (e) => {
            const btn = e.target.closest('button[data-action]');
            if (!btn) return;
            const item = btn.closest('.carrito-item');
            const id = item.getAttribute('data-id');
            const action = btn.getAttribute('data-action');
            if (action === 'incr') changeQty(id, +1);
            else if (action === 'decr') changeQty(id, -1);
            else if (action === 'rm') removeItem(id);
        });

        document.addEventListener('keydown', (e) => { if (e.key === 'Escape') cerrarPanel(); });
    }

    function wireAddButtons() {
        document.querySelectorAll('.libro-card').forEach(card => {
            let btn = card.querySelector('.btn-anadir');

            const titulo = card.querySelector('h4')?.textContent?.trim() || 'Libro';
            const autor  = card.querySelector('.autor')?.textContent?.trim() || '';
            const precioTxt = card.querySelector('.precio')?.textContent?.trim() || '$ 0';
            const precio = parseFloat(precioTxt.replace(/[^0-9.]/g, '')) || 0;
            const imagen = card.querySelector('img')?.src || '';
            const id = (card.dataset.id) || (titulo + '|' + autor).toLowerCase().replace(/\s+/g, '-');

            if (!btn) {
                btn = document.createElement('button');
                btn.className = 'btn-anadir';
                btn.innerHTML = '<i class="fas fa-cart-plus"></i> Añadir al carrito';
                card.querySelector('.libro-info').appendChild(btn);
            }

            if (btn.dataset.wired) return;
            btn.dataset.wired = "true";

            btn.addEventListener('click', (e) => {
                e.stopPropagation();
                e.preventDefault();
                addItem({ id, titulo, autor, precio, imagen });

                const originalHtml = btn.innerHTML;
                btn.classList.add('added');
                btn.innerHTML = '<i class="fas fa-check"></i> Añadido';
                setTimeout(() => {
                    btn.classList.remove('added');
                    btn.innerHTML = originalHtml;
                }, 1400);
            });
        });
    }

    function wireCartButton() {
        const btn = document.getElementById('btn-carrito');
        if (btn) btn.addEventListener('click', abrirPanel);
    }

    // --- FUNCIÓN DE ESCAPE CORREGIDA PARA EVITAR EL ERROR DE SINTAXIS ---
    function escapeHtml(s) {
        return String(s).replace(/[&<>"']/g, function(c) {
            return {
                '&': '&amp;',
                '<': '&lt;',
                '>': '&gt;',
                '"': '&quot;',
                "'": '&#39;'
            }[c];
        });
    }

    function escapeAttr(s) { return escapeHtml(s); }

    /* ============================================================
       VALIDACIÓN REAL DE TARJETAS DE CRÉDITO Y MODAL
       ============================================================ */
    function detectarMarca(num) {
        const n = num.replace(/\D/g, '');
        if (!n) return null;
        if (/^3[47]/.test(n)) return { marca: 'amex', nombre: 'AMERICAN EXPRESS', lenNum: [15], lenCvv: 4, formato: [4,6,5] };
        if (/^4/.test(n)) return { marca: 'visa', nombre: 'VISA', lenNum: [13,16,19], lenCvv: 3, formato: [4,4,4,4] };
        if (/^(5[1-5]|2(2[2-9][1-9]|2[3-9]\d{2}|[3-6]\d{3}|7([01]\d{2}|20)))/.test(n)) return { marca: 'mastercard', nombre: 'MASTERCARD', lenNum: [16], lenCvv: 3, formato: [4,4,4,4] };
        if (/^(6011|65|64[4-9]|622(12[6-9]|1[3-9]\d|[2-8]\d{2}|9([01]\d|2[0-5])))/.test(n)) return { marca: 'discover', nombre: 'DISCOVER', lenNum: [16], lenCvv: 3, formato: [4,4,4,4] };
        if (/^(30[0-5]|3095|3[689])/.test(n)) return { marca: 'diners', nombre: 'DINERS CLUB', lenNum: [14], lenCvv: 3, formato: [4,6,4] };
        return null;
    }

    function luhnValido(num) {
        const n = num.replace(/\D/g, '');
        if (n.length < 12) return false;
        let suma = 0; let doble = false;
        for (let i = n.length - 1; i >= 0; i--) {
            let d = parseInt(n.charAt(i), 10);
            if (doble) { d *= 2; if (d > 9) d -= 9; }
            suma += d; doble = !doble;
        }
        return suma % 10 === 0;
    }

    function formatearNumero(num, formato) {
        const n = num.replace(/\D/g, '');
        if (!formato) return n.replace(/(.{4})/g, '$1 ').trim();
        let out = ''; let idx = 0;
        for (const grp of formato) {
            if (idx >= n.length) break;
            if (out) out += ' '; out += n.substr(idx, grp); idx += grp;
        }
        return out;
    }

    function validarExpiracion(mmyy) {
        const m = mmyy.match(/^(\d{2})\/(\d{2})$/);
        if (!m) return false;
        const mes = parseInt(m[1], 10);
        const anio = 2000 + parseInt(m[2], 10);
        if (mes < 1 || mes > 12) return false;
        const hoy = new Date();
        const exp = new Date(anio, mes, 0, 23, 59, 59);
        return exp >= hoy;
    }

    function ensurePagoModal() {
        if (document.getElementById('pago-overlay')) return;
        const ov = document.createElement('div');
        ov.id = 'pago-overlay'; ov.className = 'pago-overlay';
        ov.innerHTML = '<div class="pago-modal" role="dialog" aria-modal="true"><div id="pago-contenido"></div></div>';
        document.body.appendChild(ov);
        ov.addEventListener('click', (e) => { if (e.target === ov) cerrarPago(); });
        document.addEventListener('keydown', (e) => { if (e.key === 'Escape' && ov.classList.contains('abierto')) cerrarPago(); });
    }

    function renderFormularioPago() {
        const cont = document.getElementById('pago-contenido');
        cont.innerHTML = '' +
            '<div class="pago-header"><div><h3><i class="fas fa-credit-card"></i> Pago seguro</h3><p>Completa los datos de tu tarjeta</p></div><button class="btn-cerrar-carrito" id="cerrar-pago" aria-label="Cerrar"><i class="fas fa-times"></i></button></div>' +
            '<div class="pago-tarjeta" id="tarjeta-preview"><span class="marca-tarjeta" id="prev-marca">FOLIO</span><div class="numero-tarjeta" id="prev-numero">•••• •••• •••• ••••</div><div class="fila-tarjeta"><div><span class="label">Titular</span><span class="valor" id="prev-titular">NOMBRE APELLIDO</span></div><div><span class="label">Vence</span><span class="valor" id="prev-expira">MM/AA</span></div></div></div>' +
            '<form id="form-pago" class="pago-body" novalidate>' +
            '<div class="form-grupo" id="g-numero"><label for="card-numero">Número de tarjeta</label><input type="text" id="card-numero" inputmode="numeric" autocomplete="cc-number" placeholder="0000 0000 0000 0000" maxlength="23" required><div class="pago-error" id="e-numero"><i class="fas fa-exclamation-circle"></i> <span></span></div></div>' +
            '<div class="form-grupo" id="g-titular"><label for="card-titular">Nombre del titular</label><input type="text" id="card-titular" autocomplete="cc-name" placeholder="Como aparece en la tarjeta" required><div class="pago-error" id="e-titular"><i class="fas fa-exclamation-circle"></i> <span></span></div></div>' +
            '<div class="fila-2"><div class="form-grupo" id="g-expira"><label for="card-expira">Vencimiento</label><input type="text" id="card-expira" inputmode="numeric" autocomplete="cc-exp" placeholder="MM/AA" maxlength="5" required><div class="pago-error" id="e-expira"><i class="fas fa-exclamation-circle"></i> <span></span></div></div>' +
            '<div class="form-grupo" id="g-cvv"><label for="card-cvv">CVV</label><input type="text" id="card-cvv" inputmode="numeric" autocomplete="cc-csc" placeholder="123" maxlength="4" required><div class="pago-error" id="e-cvv"><i class="fas fa-exclamation-circle"></i> <span></span></div></div></div>' +
            '<div class="pago-resumen"><span>Total a pagar:</span><span class="total">$ ' + total().toFixed(2) + '</span></div>' +
            '</form>' +
            '<div class="pago-footer"><button type="button" class="btn-pagar" id="btn-pagar"><i class="fas fa-lock"></i> Pagar $ ' + total().toFixed(2) + '</button><button type="button" class="btn-cancelar" id="btn-cancelar">Cancelar</button><div class="pago-seguro"><i class="fas fa-shield-alt"></i> Conexión cifrada · No almacenamos tu tarjeta</div></div>';
        wirePagoForm();
    }

    function wirePagoForm() {
        document.getElementById('cerrar-pago').addEventListener('click', cerrarPago);
        document.getElementById('btn-cancelar').addEventListener('click', cerrarPago);

        const numIn = document.getElementById('card-numero');
        const titIn = document.getElementById('card-titular');
        const expIn = document.getElementById('card-expira');
        const cvvIn = document.getElementById('card-cvv');
        const tarjeta = document.getElementById('tarjeta-preview');

        let marcaActual = null;

        numIn.addEventListener('input', () => {
            const raw = numIn.value.replace(/\D/g, '').slice(0, 19);
            const det = detectarMarca(raw);
            marcaActual = det;
            const fmt = det ? det.formato : null;
            numIn.value = formatearNumero(raw, fmt);
            document.getElementById('prev-numero').textContent = (numIn.value + ' •••• •••• •••• ••••').slice(0, 19 + 4);
            document.getElementById('prev-marca').textContent = det ? det.nombre : 'FOLIO';
            tarjeta.className = 'pago-tarjeta' + (det ? ' ' + det.marca : '');
            cvvIn.maxLength = det && det.lenCvv === 4 ? 4 : 3;
            validarCampo('numero');
        });

        titIn.addEventListener('input', () => {
            titIn.value = titIn.value.replace(/[^A-Za-zÁÉÍÓÚáéíóúÑñ\s]/g, '').toUpperCase().slice(0, 40);
            document.getElementById('prev-titular').textContent = titIn.value || 'NOMBRE APELLIDO';
            validarCampo('titular');
        });

        expIn.addEventListener('input', () => {
            let v = expIn.value.replace(/\D/g, '').slice(0, 4);
            if (v.length >= 3) v = v.slice(0, 2) + '/' + v.slice(2);
            expIn.value = v;
            document.getElementById('prev-expira').textContent = v || 'MM/AA';
            validarCampo('expira');
        });

        cvvIn.addEventListener('input', () => {
            cvvIn.value = cvvIn.value.replace(/\D/g, '').slice(0, cvvIn.maxLength);
            validarCampo('cvv');
        });

        function validarCampo(campo) {
            const g = (id) => document.getElementById(id);
            if (campo === 'numero') {
                const raw = numIn.value.replace(/\D/g, '');
                const det = marcaActual;
                const grp = g('g-numero'), err = g('e-numero');
                grp.classList.remove('valid', 'invalid'); err.classList.remove('visible');
                if (raw.length === 0) return;
                if (!det) { err.querySelector('span').textContent = 'Marca no reconocida (Visa, MC, Amex, Discover).'; err.classList.add('visible'); grp.classList.add('invalid'); return; }
                if (!det.lenNum.includes(raw.length)) { if (raw.length < Math.min(...det.lenNum)) return; err.querySelector('span').textContent = det.nombre + ' requiere ' + det.lenNum.join(' o ') + ' dígitos.'; err.classList.add('visible'); grp.classList.add('invalid'); return; }
                if (!luhnValido(raw)) { err.querySelector('span').textContent = 'Número de tarjeta inválido (Luhn).'; err.classList.add('visible'); grp.classList.add('invalid'); return; }
                grp.classList.add('valid');
            }
            else if (campo === 'titular') {
                const v = titIn.value.trim();
                const grp = g('g-titular'), err = g('e-titular');
                grp.classList.remove('valid', 'invalid'); err.classList.remove('visible');
                if (v.length === 0) return;
                if (v.length < 5 || !v.includes(' ')) { err.querySelector('span').textContent = 'Ingresa nombre y apellido.'; err.classList.add('visible'); grp.classList.add('invalid'); return; }
                grp.classList.add('valid');
            }
            else if (campo === 'expira') {
                const v = expIn.value;
                const grp = g('g-expira'), err = g('e-expira');
                grp.classList.remove('valid', 'invalid'); err.classList.remove('visible');
                if (v.length === 0) return;
                if (v.length < 5) return;
                if (!validarExpiracion(v)) { err.querySelector('span').textContent = 'Fecha vencida.'; err.classList.add('visible'); grp.classList.add('invalid'); return; }
                grp.classList.add('valid');
            }
            else if (campo === 'cvv') {
                const v = cvvIn.value;
                const grp = g('g-cvv'), err = g('e-cvv');
                grp.classList.remove('valid', 'invalid'); err.classList.remove('visible');
                const needed = marcaActual ? marcaActual.lenCvv : 3;
                if (v.length === 0) return;
                if (v.length !== needed) { if (v.length < needed) return; err.querySelector('span').textContent = 'CVV de ' + needed + ' dígitos.'; err.classList.add('visible'); grp.classList.add('invalid'); return; }
                grp.classList.add('valid');
            }
        }

        document.getElementById('btn-pagar').addEventListener('click', () => {
            ['numero','titular','expira','cvv'].forEach(validarCampo);
            const raw = numIn.value.replace(/\D/g, '');
            const det = marcaActual;
            const tit = titIn.value.trim();
            const exp = expIn.value;
            const cvv = cvvIn.value;

            if (!det || !det.lenNum.includes(raw.length) || !luhnValido(raw)) { numIn.focus(); return; }
            if (tit.length < 5 || !tit.includes(' ')) { titIn.focus(); return; }
            if (!validarExpiracion(exp)) { expIn.focus(); return; }
            if (cvv.length !== det.lenCvv) { cvvIn.focus(); return; }

            procesarPago(det.nombre, raw.slice(-4));
        });
        numIn.focus();
    }

    function procesarPago(marca, ultimos4) {
        const cont = document.getElementById('pago-contenido');
        const monto = total().toFixed(2);
        const email = getUserEmail();
        cont.innerHTML = '<div class="pago-exito"><div class="check"><i class="fas fa-check"></i></div><h3>¡Pago aprobado!</h3><p>Tu compra de <strong>$ ' + monto + '</strong> fue procesada con éxito.</p><p style="font-size:0.9rem;color:var(--color-texto-suave);">' + marca + ' terminada en •••• ' + ultimos4 + '<br>Recibo enviado a <strong>' + email + '</strong></p></div><div class="pago-footer"><button type="button" class="btn-pagar" id="btn-cerrar-exito">Continuar</button></div>';
        document.getElementById('btn-cerrar-exito').addEventListener('click', () => { clearCart(); cerrarPago(); cerrarPanel(); });
    }

    function abrirPago() { ensurePagoModal(); renderFormularioPago(); document.getElementById('pago-overlay').classList.add('abierto'); }
    function cerrarPago() { const ov = document.getElementById('pago-overlay'); if (ov) ov.classList.remove('abierto'); }

    window.FolioCarrito = { add: addItem, remove: removeItem, clear: clearCart, open: abrirPanel, close: cerrarPanel, openPago: abrirPago, setUser: setUser, logout: logout, count: count, total: total, luhn: luhnValido, marca: detectarMarca };

    document.addEventListener('DOMContentLoaded', () => { ensureDrawer(); wireCartButton(); wireAddButtons(); renderBadge(); });
})();