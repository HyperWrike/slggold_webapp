/**
 * Dynamically loads and runs Razorpay Checkout SDK on web
 */
export function openRazorpayCheckout(
  orderData: {
    key: string;
    amount: number;
    currency: string;
    orderId: string;
  },
  onSuccess: (paymentId: string, signature: string) => void,
  onFailure: (error: string) => void
): void {
  if (typeof window === "undefined") {
    onFailure("Window is undefined");
    return;
  }

  const triggerRzp = () => {
    const options = {
      key: orderData.key,
      amount: Math.round(orderData.amount * 100), // paise
      currency: orderData.currency || "INR",
      name: "SLG Golds",
      description: "Savings Scheme Installment Payment",
      order_id: orderData.orderId,
      handler: function (response: any) {
        if (response.razorpay_payment_id && response.razorpay_signature) {
          onSuccess(response.razorpay_payment_id, response.razorpay_signature);
        } else {
          onFailure("Payment verification details missing from SDK response");
        }
      },
      modal: {
        ondismiss: function () {
          onFailure("Payment cancelled by user");
        },
      },
      prefill: {
        name: "",
        email: "",
        contact: "",
      },
      theme: {
        color: "#B8860B", // Gold
      },
    };
    const rzp = new (window as any).Razorpay(options);
    rzp.open();
  };

  // Dynamically load Razorpay checkout script if not loaded
  if (!(window as any).Razorpay) {
    const script = document.createElement("script");
    script.src = "https://checkout.razorpay.com/v1/checkout.js";
    script.async = true;
    script.onload = () => {
      triggerRzp();
    };
    script.onerror = () => {
      onFailure("Failed to load Razorpay SDK checkout script");
    };
    document.body.appendChild(script);
  } else {
    triggerRzp();
  }
}
