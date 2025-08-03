import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["header", "cardHeader"]

    connect() {
        this.sortColumn = null;
        this.sortDirection = 1;
        this.lastSortedHeader = null;
        this.updateAllIndicators();
    }

    sort(event) {
        const th = event.currentTarget;
        const table = th.closest("table");
        const tbody = table.querySelector("tbody");
        const index = Array.from(th.parentNode.children).indexOf(th);
        const rows = Array.from(tbody.querySelectorAll("tr"));
        const type = th.dataset.type || "string";

        if (this.sortColumn === index) {
            this.sortDirection *= -1;
        } else {
            this.sortDirection = 1;
            this.sortColumn = index;
        }
        this.updateAllIndicators(table, index);
        rows.sort((a, b) => {
            let aText = a.children[index].innerText.trim();
            let bText = b.children[index].innerText.trim();
            if (type === "number") {
                aText = parseFloat(aText.replace(/[^\d.-]/g, "")) || 0;
                bText = parseFloat(bText.replace(/[^\d.-]/g, "")) || 0;
            } else if (type === "date") {
                aText = new Date(aText);
                bText = new Date(bText);
            }
            if (aText < bText) return -1 * this.sortDirection;
            if (aText > bText) return 1 * this.sortDirection;
            return 0;
        });
        rows.forEach(row => tbody.appendChild(row));
    }

    sortCards(event) {
        const btn = event.currentTarget;
        const container = document.getElementById(btn.dataset.cardsContainer);
        const cards = Array.from(container.querySelectorAll("[data-card]")).filter(card => card.parentNode === container);
        const type = btn.dataset.type || "string";
        const key = btn.dataset.key;
        if (this.sortColumn === key) {
            this.sortDirection *= -1;
        } else {
            this.sortDirection = 1;
            this.sortColumn = key;
        }
        this.updateAllIndicators(null, null, btn);
        cards.sort((a, b) => {
            let aText = a.dataset[key] || "";
            let bText = b.dataset[key] || "";
            if (type === "number") {
                aText = parseFloat(aText.replace(/[^\d.-]/g, "")) || 0;
                bText = parseFloat(bText.replace(/[^\d.-]/g, "")) || 0;
            } else if (type === "date") {
                aText = new Date(aText);
                bText = new Date(bText);
            }
            if (aText < bText) return -1 * this.sortDirection;
            if (aText > bText) return 1 * this.sortDirection;
            return 0;
        });
        cards.forEach(card => container.appendChild(card));
    }

    updateAllIndicators(table = null, colIndex = null, btn = null) {
        // Table headers
        const ths = table ? table.querySelectorAll('th') : document.querySelectorAll('table[data-controller="table-sort"] th');
        ths.forEach((th, i) => {
            const up = th.querySelector('.sort-up-id, .sort-up-date, .sort-up-status, .sort-up-channels, .sort-up-likes');
            const down = th.querySelector('.sort-down-id, .sort-down-date, .sort-down-status, .sort-down-channels, .sort-down-likes');
            if (up && down) {
                if (colIndex !== null && i === colIndex) {
                    up.classList.toggle('text-black', this.sortDirection === 1);
                    up.classList.toggle('text-gray-400', this.sortDirection !== 1);
                    down.classList.toggle('text-black', this.sortDirection === -1);
                    down.classList.toggle('text-gray-400', this.sortDirection !== -1);
                } else {
                    up.classList.remove('text-black');
                    up.classList.add('text-gray-400');
                    down.classList.remove('text-black');
                    down.classList.add('text-gray-400');
                }
            }
        });
        // Mobile sort buttons
        const btns = document.querySelectorAll('button[data-action*="sortCards"]');
        btns.forEach(b => {
            const key = b.dataset.key;
            const up = b.querySelector('.sort-up-id, .sort-up-date, .sort-up-status');
            const down = b.querySelector('.sort-down-id, .sort-down-date, .sort-down-status');
            if (up && down) {
                if (btn && b === btn) {
                    up.classList.toggle('text-black', this.sortDirection === 1);
                    up.classList.toggle('text-gray-400', this.sortDirection !== 1);
                    down.classList.toggle('text-black', this.sortDirection === -1);
                    down.classList.toggle('text-gray-400', this.sortDirection !== -1);
                } else {
                    up.classList.remove('text-black');
                    up.classList.add('text-gray-400');
                    down.classList.remove('text-black');
                    down.classList.add('text-gray-400');
                }
            }
        });
    }
}