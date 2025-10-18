import React from 'react';
import { MenuItem, CartItem } from '../types';
import { useCategories } from '../hooks/useCategories';
import MenuItemCard from './MenuItemCard';

// Preload images for better performance
const preloadImages = (items: MenuItem[]) => {
  items.forEach(item => {
    if (item.image) {
      const img = new Image();
      img.src = item.image;
    }
  });
};

interface MenuProps {
  menuItems: MenuItem[];
  addToCart: (item: MenuItem, quantity?: number, variation?: any, addOns?: any[]) => void;
  cartItems: CartItem[];
  updateQuantity: (id: string, quantity: number) => void;
  selectedCategory: string;
}

const Menu: React.FC<MenuProps> = ({ menuItems, addToCart, cartItems, updateQuantity, selectedCategory }) => {
  const { categories } = useCategories();

  // Preload images when menu items change
  React.useEffect(() => {
    if (menuItems.length > 0) {
      preloadImages(menuItems);
    }
  }, [menuItems]);


  // Filter categories based on selection
  const categoriesToShow = selectedCategory === 'all' 
    ? categories 
    : categories.filter(cat => cat.id === selectedCategory);

  return (
    <>
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div className="text-center mb-12">
        <h2 className="text-4xl font-bold text-firehouse-charcoal mb-4">Our Menu</h2>
        <p className="text-firehouse-gray max-w-2xl mx-auto">
          Experience the perfect blend of comfort food and vibrant atmosphere at Firehouse Lounge & Resto. 
          From crispy starters to refreshing beverages, every dish is crafted with care.
        </p>
      </div>

      {categoriesToShow.map((category) => {
        const categoryItems = menuItems.filter(item => {
          // Match by ID (kebab-case) or by name
          const itemCategoryId = item.category.toLowerCase().replace(/\s+/g, '-');
          return itemCategoryId === category.id || item.category === category.name;
        });
        
        if (categoryItems.length === 0) return null;
        
        return (
          <section key={category.id} id={category.id} className="mb-16">
            <div className="flex items-center mb-8">
              <span className="text-3xl mr-3">{category.icon}</span>
              <h3 className="text-3xl font-bold text-firehouse-charcoal">{category.name}</h3>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {categoryItems.map((item) => {
                // Find all cart items that are based on this menu item
                const relatedCartItems = cartItems.filter(cartItem => 
                  cartItem.id.startsWith(`${item.id}-`)
                );
                
                // Sum up quantities of all related cart items
                const totalQuantity = relatedCartItems.reduce((sum, cartItem) => sum + cartItem.quantity, 0);
                
                // For simple items (no variations/addons), find the exact cart item
                const simpleCartItem = relatedCartItems.find(cartItem => 
                  !cartItem.selectedVariation && (!cartItem.selectedAddOns || cartItem.selectedAddOns.length === 0)
                );
                
                return (
                  <MenuItemCard
                    key={item.id}
                    item={item}
                    onAddToCart={addToCart}
                    quantity={totalQuantity}
                    onUpdateQuantity={updateQuantity}
                    categoryEmoji={category.icon}
                    cartItemId={simpleCartItem?.id}
                  />
                );
              })}
            </div>
          </section>
        );
      })}
      </main>
    </>
  );
};

export default Menu;