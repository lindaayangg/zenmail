import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="subscription"
export default class extends Controller {
    static values = {
        billingPortalPath: String,
        checkoutSessionPath: String,
        stripeKey: String
    }

    openBillingPortal(event) {
        event.preventDefault();
        fetch(this.billingPortalPathValue, {
                method: 'POST',
                headers: {
                    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
                    'Accept': 'application/json'
                }
            })
            .then(response => response.json())
            .then(data => {
                if (data.url) {
                    window.location = data.url;
                } else {
                    alert('Could not open billing portal. Please try again.');
                }
            });
    }

    subscribeWithStripe(event) {
        event.preventDefault();
        const priceId = event.target.dataset.priceId;
        fetch(this.checkoutSessionPathValue, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
                },
                body: JSON.stringify({ price_id: priceId })
            })
            .then(response => response.json())
            .then(session => {
                if (session.id) {
                    const stripe = Stripe(this.stripeKeyValue);
                    stripe.redirectToCheckout({ sessionId: session.id });
                } else {
                    alert(session.error || 'Failed to create checkout session.');
                }
            });
    }
}