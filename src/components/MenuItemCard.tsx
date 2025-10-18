import React, { useState } from 'react';
import { X, ShoppingCart } from 'lucide-react';
import { MenuItem, Variation, AddOn } from '../types';

interface MenuItemCardProps {
  item: MenuItem;
  onAddToCart: (item: MenuItem, quantity?: number, variation?: Variation, addOns?: AddOn[]) => void;
  categoryEmoji?: string;
}

const MenuItemCard: React.FC<MenuItemCardProps> = ({ 
  item, 
  onAddToCart, 
  categoryEmoji
}) => {
  const [showCustomization, setShowCustomization] = useState(false);
  const [selectedVariation, setSelectedVariation] = useState<Variation | undefined>(
    // For Cold Beverages, default to first variation (flavor choice required)
    // For other items, default to no variation (Regular option)
    item.category === 'Cold Beverages' ? item.variations?.[0] : undefined
  );
  const [selectedAddOns, setSelectedAddOns] = useState<(AddOn & { quantity: number })[]>([]);

  const calculatePrice = () => {
    // Use effective price (discounted or regular) as base
    let price = item.effectivePrice || item.basePrice;
    if (selectedVariation) {
      price = (item.effectivePrice || item.basePrice) + selectedVariation.price;
    }
    selectedAddOns.forEach(addOn => {
      price += addOn.price * addOn.quantity;
    });
    return price;
  };

  const handleAddToCart = () => {
    if (item.variations?.length || item.addOns?.length) {
      setShowCustomization(true);
    } else {
      onAddToCart(item, 1);
    }
  };

  const handleCustomizedAddToCart = () => {
    // Convert selectedAddOns back to regular AddOn array for cart
    const addOnsForCart: AddOn[] = selectedAddOns.flatMap(addOn => 
      Array(addOn.quantity).fill({ ...addOn, quantity: undefined })
    );
    onAddToCart(item, 1, selectedVariation, addOnsForCart);
    setShowCustomization(false);
    setSelectedAddOns([]);
  };


  const updateAddOnQuantity = (addOn: AddOn, quantity: number) => {
    setSelectedAddOns(prev => {
      const existingIndex = prev.findIndex(a => a.id === addOn.id);
      
      if (quantity === 0) {
        // Remove add-on if quantity is 0
        return prev.filter(a => a.id !== addOn.id);
      }
      
      if (existingIndex >= 0) {
        // Update existing add-on quantity
        const updated = [...prev];
        updated[existingIndex] = { ...updated[existingIndex], quantity };
        return updated;
      } else {
        // Add new add-on with quantity
        return [...prev, { ...addOn, quantity }];
      }
    });
  };

  const groupedAddOns = item.addOns?.reduce((groups, addOn) => {
    const category = addOn.category;
    if (!groups[category]) {
      groups[category] = [];
    }
    groups[category].push(addOn);
    return groups;
  }, {} as Record<string, AddOn[]>);

  return (
    <>
      <div className={`bg-firehouse-white rounded-2xl shadow-sm hover:shadow-xl transition-all duration-300 overflow-hidden group animate-scale-in border border-firehouse-yellow/20 ${!item.available ? 'opacity-60' : ''}`}>
        {/* Image Container with Badges */}
        <div className="relative h-48 bg-gradient-to-br from-firehouse-off-white to-firehouse-off-white-dark">
          {item.image ? (
            <img
              src={item.image}
              alt={item.name}
              className="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105"
              loading="lazy"
              decoding="async"
              onError={(e) => {
                e.currentTarget.style.display = 'none';
                e.currentTarget.nextElementSibling?.classList.remove('hidden');
              }}
            />
          ) : null}
          <div className={`absolute inset-0 flex items-center justify-center ${item.image ? 'hidden' : ''}`}>
            <div className="text-6xl opacity-20 text-gray-400">{categoryEmoji || '🍽️'}</div>
          </div>
          
          {/* Badges */}
          <div className="absolute top-3 left-3 flex flex-col gap-2">
            {item.isOnDiscount && item.discountPrice && (
              <div className="bg-gradient-to-r from-firehouse-red to-firehouse-red-light text-white text-xs font-bold px-3 py-1.5 rounded-full shadow-lg animate-pulse">
                SALE
              </div>
            )}
            {item.popular && (
              <div className="bg-gradient-to-r from-firehouse-yellow to-firehouse-yellow-light text-firehouse-charcoal text-xs font-bold px-3 py-1.5 rounded-full shadow-lg">
                ⭐ POPULAR
              </div>
            )}
          </div>
          
          {!item.available && (
            <div className="absolute top-3 right-3 bg-firehouse-gray text-white text-xs font-bold px-3 py-1.5 rounded-full shadow-lg">
              UNAVAILABLE
            </div>
          )}
          
          {/* Discount Percentage Badge */}
          {item.isOnDiscount && item.discountPrice && (
            <div className="absolute bottom-3 right-3 bg-firehouse-white/90 backdrop-blur-sm text-firehouse-red text-xs font-bold px-2 py-1 rounded-full shadow-lg">
              {Math.round(((item.basePrice - item.discountPrice) / item.basePrice) * 100)}% OFF
            </div>
          )}
        </div>
        
        {/* Content */}
        <div className="p-5">
          <div className="flex items-start justify-between mb-3">
            <h4 className="text-lg font-semibold text-firehouse-charcoal leading-tight flex-1 pr-2 flex items-center gap-2">
              {categoryEmoji && <span className="text-xl">{categoryEmoji}</span>}
              {item.name}
            </h4>
            {item.variations && item.variations.length > 0 && (
              <div className="text-xs text-firehouse-gray bg-firehouse-yellow/10 px-2 py-1 rounded-full whitespace-nowrap border border-firehouse-yellow/20">
                {item.variations.length} sizes
              </div>
            )}
          </div>
          
          <p className={`text-sm mb-4 leading-relaxed ${!item.available ? 'text-firehouse-gray-light' : 'text-firehouse-gray'}`}>
            {!item.available ? 'Currently Unavailable' : item.description}
          </p>
          
          {/* Pricing Section */}
          <div className="flex items-center justify-between mb-4">
            <div className="flex-1">
              {item.isOnDiscount && item.discountPrice ? (
                <div className="space-y-1">
                  <div className="flex items-center space-x-2">
                    <span className="text-2xl font-bold text-firehouse-red">
                      ₱{item.discountPrice.toFixed(2)}
                    </span>
                    <span className="text-sm text-firehouse-gray line-through">
                      ₱{item.basePrice.toFixed(2)}
                    </span>
                  </div>
                  <div className="text-xs text-firehouse-gray">
                    Save ₱{(item.basePrice - item.discountPrice).toFixed(2)}
                  </div>
                </div>
              ) : (
                <div className="text-2xl font-bold text-firehouse-charcoal">
                  ₱{item.basePrice.toFixed(2)}
                </div>
              )}
              
              {item.variations && item.variations.length > 0 && (
                <div className="text-xs text-firehouse-gray mt-1">
                  Starting price
                </div>
              )}
            </div>
            
            {/* Action Buttons */}
            <div className="flex-shrink-0">
              {!item.available ? (
                <button
                  disabled
                  className="bg-firehouse-gray-light text-firehouse-gray px-4 py-2.5 rounded-xl cursor-not-allowed font-medium text-sm"
                >
                  Unavailable
                </button>
              ) : (
                <button
                  onClick={handleAddToCart}
                  className="bg-gradient-to-r from-firehouse-yellow to-firehouse-yellow-light text-firehouse-charcoal px-6 py-2.5 rounded-xl hover:from-firehouse-yellow-dark hover:to-firehouse-yellow transition-all duration-200 transform hover:scale-105 font-bold text-sm shadow-lg hover:shadow-xl"
                >
                  {item.variations?.length || item.addOns?.length ? 'Customize' : 'Add to Cart'}
                </button>
              )}
            </div>
          </div>

          {/* Add-ons indicator */}
          {item.addOns && item.addOns.length > 0 && (
            <div className="flex items-center space-x-1 text-xs text-firehouse-gray bg-firehouse-yellow/10 px-2 py-1 rounded-lg border border-firehouse-yellow/20">
              <span>+</span>
              <span>{item.addOns.length} add-on{item.addOns.length > 1 ? 's' : ''} available</span>
            </div>
          )}
        </div>
      </div>

      {/* Customization Modal */}
      {showCustomization && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
          <div className="bg-firehouse-white rounded-2xl max-w-md w-full max-h-[90vh] overflow-y-auto shadow-2xl">
            <div className="sticky top-0 bg-firehouse-white border-b border-firehouse-yellow/20 p-6 flex items-center justify-between rounded-t-2xl">
              <div>
                <h3 className="text-xl font-semibold text-firehouse-charcoal">Customize {item.name}</h3>
                <p className="text-sm text-firehouse-gray mt-1">Choose your preferences</p>
              </div>
              <button
                onClick={() => setShowCustomization(false)}
                className="p-2 hover:bg-firehouse-yellow/10 rounded-full transition-colors duration-200"
              >
                <X className="h-5 w-5 text-firehouse-gray" />
              </button>
            </div>

            <div className="p-6">
              {/* Size Variations */}
              {item.variations && item.variations.length > 0 && (
                <div className="mb-6">
                  <h4 className="font-semibold text-gray-900 mb-4">
                    {item.category === 'Cold Beverages' ? 'Choose Flavor' : 'Choose Size'}
                  </h4>
                  <div className="space-y-3">
                    {/* Regular/Base price option - only show for non-Cold Beverages */}
                    {item.category !== 'Cold Beverages' && (
                      <label
                        className={`flex items-center justify-between p-4 border-2 rounded-xl cursor-pointer transition-all duration-200 ${
                          !selectedVariation
                            ? 'border-firehouse-yellow bg-firehouse-yellow/10'
                            : 'border-gray-200 hover:border-gray-300 hover:bg-gray-50'
                        }`}
                      >
                        <div className="flex items-center space-x-3">
                          <input
                            type="radio"
                            name="variation"
                            checked={!selectedVariation}
                            onChange={() => setSelectedVariation(undefined)}
                            className="text-firehouse-yellow focus:ring-firehouse-yellow"
                          />
                          <span className="font-medium text-gray-900">Regular</span>
                        </div>
                        <span className="text-gray-900 font-semibold">
                          ₱{(item.effectivePrice || item.basePrice).toFixed(2)}
                        </span>
                      </label>
                    )}
                    
                    {/* Variation options */}
                    {item.variations.map((variation) => (
                      <label
                        key={variation.id}
                        className={`flex items-center justify-between p-4 border-2 rounded-xl cursor-pointer transition-all duration-200 ${
                          selectedVariation?.id === variation.id
                            ? 'border-firehouse-yellow bg-firehouse-yellow/10'
                            : 'border-gray-200 hover:border-gray-300 hover:bg-gray-50'
                        }`}
                      >
                        <div className="flex items-center space-x-3">
                          <input
                            type="radio"
                            name="variation"
                            checked={selectedVariation?.id === variation.id}
                            onChange={() => setSelectedVariation(variation)}
                            className="text-firehouse-yellow focus:ring-firehouse-yellow"
                          />
                          <span className="font-medium text-gray-900">{variation.name}</span>
                        </div>
                        <span className="text-gray-900 font-semibold">
                          ₱{((item.effectivePrice || item.basePrice) + variation.price).toFixed(2)}
                        </span>
                      </label>
                    ))}
                  </div>
                </div>
              )}

              {/* Add-ons */}
              {groupedAddOns && Object.keys(groupedAddOns).length > 0 && (
                <div className="mb-6">
                  <h4 className="font-semibold text-gray-900 mb-4">Add-ons</h4>
                  {Object.entries(groupedAddOns).map(([category, addOns]) => (
                    <div key={category} className="mb-4">
                      <h5 className="text-sm font-medium text-gray-700 mb-3 capitalize">
                        {category.replace('-', ' ')}
                      </h5>
                      <div className="space-y-3">
                        {addOns.map((addOn) => (
                          <div
                            key={addOn.id}
                            className="flex items-center justify-between p-4 border border-gray-200 rounded-xl hover:border-gray-300 hover:bg-gray-50 transition-all duration-200"
                          >
                            <div className="flex-1">
                              <span className="font-medium text-gray-900">{addOn.name}</span>
                              <div className="text-sm text-gray-600">
                                {addOn.price > 0 ? `₱${addOn.price.toFixed(2)} each` : 'Free'}
                              </div>
                            </div>
                            
                            <div className="flex items-center space-x-2">
                              {selectedAddOns.find(a => a.id === addOn.id) ? (
                                <div className="flex items-center space-x-2 bg-firehouse-yellow/20 rounded-xl p-1 border border-firehouse-yellow/30">
                                  <button
                                    type="button"
                                    onClick={() => {
                                      const current = selectedAddOns.find(a => a.id === addOn.id);
                                      updateAddOnQuantity(addOn, (current?.quantity || 1) - 1);
                                    }}
                                    className="p-1.5 hover:bg-firehouse-yellow/30 rounded-lg transition-colors duration-200"
                                  >
                                    <Minus className="h-3 w-3 text-firehouse-yellow" />
                                  </button>
                                  <span className="font-semibold text-gray-900 min-w-[24px] text-center text-sm">
                                    {selectedAddOns.find(a => a.id === addOn.id)?.quantity || 0}
                                  </span>
                                  <button
                                    type="button"
                                    onClick={() => {
                                      const current = selectedAddOns.find(a => a.id === addOn.id);
                                      updateAddOnQuantity(addOn, (current?.quantity || 0) + 1);
                                    }}
                                    className="p-1.5 hover:bg-firehouse-yellow/30 rounded-lg transition-colors duration-200"
                                  >
                                    <Plus className="h-3 w-3 text-firehouse-yellow" />
                                  </button>
                                </div>
                              ) : (
                                <button
                                  type="button"
                                  onClick={() => updateAddOnQuantity(addOn, 1)}
                                  className="flex items-center space-x-1 px-4 py-2 bg-gradient-to-r from-firehouse-yellow to-firehouse-yellow-dark text-firehouse-charcoal rounded-xl hover:from-firehouse-yellow-dark hover:to-firehouse-yellow transition-all duration-200 text-sm font-medium shadow-lg"
                                >
                                  <Plus className="h-3 w-3" />
                                  <span>Add</span>
                                </button>
                              )}
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  ))}
                </div>
              )}

              {/* Price Summary */}
              <div className="border-t border-gray-200 pt-4 mb-6">
                <div className="flex items-center justify-between text-2xl font-bold text-gray-900">
                  <span>Total:</span>
                  <span className="text-firehouse-yellow">₱{calculatePrice().toFixed(2)}</span>
                </div>
              </div>

              <button
                onClick={handleCustomizedAddToCart}
                className="w-full bg-gradient-to-r from-firehouse-yellow to-firehouse-yellow-dark text-firehouse-charcoal py-4 rounded-xl hover:from-firehouse-yellow-dark hover:to-firehouse-yellow transition-all duration-200 font-semibold flex items-center justify-center space-x-2 shadow-lg hover:shadow-xl transform hover:scale-105"
              >
                <ShoppingCart className="h-5 w-5" />
                <span>Add to Cart - ₱{calculatePrice().toFixed(2)}</span>
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default MenuItemCard;