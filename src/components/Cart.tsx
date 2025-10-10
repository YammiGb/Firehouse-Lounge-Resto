import React from 'react';
import { Trash2, Plus, Minus, ArrowLeft } from 'lucide-react';
import { CartItem } from '../types';

interface CartProps {
  cartItems: CartItem[];
  updateQuantity: (id: string, quantity: number) => void;
  removeFromCart: (id: string) => void;
  clearCart: () => void;
  getTotalPrice: () => number;
  onContinueShopping: () => void;
  onCheckout: () => void;
}

const Cart: React.FC<CartProps> = ({
  cartItems,
  updateQuantity,
  removeFromCart,
  clearCart,
  getTotalPrice,
  onContinueShopping,
  onCheckout
}) => {
  if (cartItems.length === 0) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-12">
        <div className="text-center py-16">
          <div className="text-6xl mb-4">🍽️</div>
          <h2 className="text-2xl font-bold text-firehouse-charcoal mb-2">Your cart is empty</h2>
          <p className="text-firehouse-gray mb-6">Add some delicious items to get started!</p>
          <button
            onClick={onContinueShopping}
            className="bg-firehouse-yellow text-firehouse-charcoal px-6 py-3 rounded-full hover:bg-firehouse-yellow-dark transition-all duration-200 font-bold shadow-lg"
          >
            Browse Menu
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto px-4 py-8">
      <div className="flex items-center justify-between mb-8">
        <button
          onClick={onContinueShopping}
          className="flex items-center space-x-2 text-firehouse-gray hover:text-firehouse-charcoal transition-colors duration-200"
        >
          <ArrowLeft className="h-5 w-5" />
          <span>Continue Shopping</span>
        </button>
        <h1 className="text-3xl font-bold text-firehouse-charcoal">Your Cart</h1>
        <button
          onClick={clearCart}
          className="text-firehouse-red hover:text-firehouse-red-light transition-colors duration-200 font-medium"
        >
          Clear All
        </button>
      </div>

      <div className="bg-firehouse-white rounded-xl shadow-sm overflow-hidden mb-8 border border-firehouse-yellow/20">
        {cartItems.map((item, index) => (
          <div key={item.id} className={`p-4 sm:p-6 ${index !== cartItems.length - 1 ? 'border-b border-firehouse-yellow/20' : ''}`}>
            <div className="flex flex-col sm:flex-row sm:items-center gap-4">
              {/* Item Details - Left Side */}
              <div className="flex-1 min-w-0">
                <h3 className="text-lg font-semibold text-firehouse-charcoal mb-2 leading-tight">{item.name}</h3>
                
                {/* Variation and Add-ons */}
                <div className="space-y-1 mb-3">
                  {item.selectedVariation && (
                    <p className="text-sm text-firehouse-gray">Size: {item.selectedVariation.name}</p>
                  )}
                  {item.selectedAddOns && item.selectedAddOns.length > 0 && (
                    <p className="text-sm text-firehouse-gray">
                      Add-ons: {item.selectedAddOns.map(addOn => 
                        addOn.quantity && addOn.quantity > 1 
                          ? `${addOn.name} x${addOn.quantity}`
                          : addOn.name
                      ).join(', ')}
                    </p>
                  )}
                </div>
                
                {/* Price per item */}
                <div className="flex items-center gap-2">
                  <span className="text-base font-semibold text-firehouse-charcoal">₱{item.totalPrice.toFixed(2)}</span>
                  <span className="text-sm text-firehouse-gray">each</span>
                </div>
              </div>
              
              {/* Controls and Total - Right Side */}
              <div className="flex items-center justify-between sm:justify-end gap-4 sm:gap-6">
                {/* Quantity Controls */}
                <div className="flex items-center space-x-3 bg-firehouse-yellow/20 rounded-full p-1 border border-firehouse-yellow/30">
                  <button
                    onClick={() => updateQuantity(item.id, item.quantity - 1)}
                    className="p-2 hover:bg-firehouse-yellow/30 rounded-full transition-colors duration-200"
                  >
                    <Minus className="h-4 w-4 text-firehouse-charcoal" />
                  </button>
                  <span className="font-semibold text-firehouse-charcoal min-w-[32px] text-center">{item.quantity}</span>
                  <button
                    onClick={() => updateQuantity(item.id, item.quantity + 1)}
                    className="p-2 hover:bg-firehouse-yellow/30 rounded-full transition-colors duration-200"
                  >
                    <Plus className="h-4 w-4 text-firehouse-charcoal" />
                  </button>
                </div>
                
                {/* Total Price */}
                <div className="text-right">
                  <p className="text-lg font-bold text-firehouse-charcoal">₱{(item.totalPrice * item.quantity).toFixed(2)}</p>
                </div>
                
                {/* Remove Button */}
                <button
                  onClick={() => removeFromCart(item.id)}
                  className="p-2 text-firehouse-red hover:text-firehouse-red-light hover:bg-firehouse-red/10 rounded-full transition-all duration-200"
                >
                  <Trash2 className="h-4 w-4" />
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="bg-firehouse-white rounded-xl shadow-sm p-6 border border-firehouse-yellow/20">
        <div className="flex items-center justify-between text-2xl font-bold text-firehouse-charcoal mb-6">
          <span>Total:</span>
          <span>₱{parseFloat(getTotalPrice() || 0).toFixed(2)}</span>
        </div>
        
        <button
          onClick={onCheckout}
          className="w-full bg-firehouse-yellow text-firehouse-charcoal py-4 rounded-xl hover:bg-firehouse-yellow-dark transition-all duration-200 transform hover:scale-[1.02] font-bold text-lg shadow-lg"
        >
          Proceed to Checkout
        </button>
      </div>
    </div>
  );
};

export default Cart;