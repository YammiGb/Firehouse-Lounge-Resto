import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { MenuItem } from '../types';

export const useMenu = () => {
  const [menuItems, setMenuItems] = useState<MenuItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchMenuItems = async () => {
    try {
      setLoading(true);
      
      // Fetch menu items with their variations and add-ons
      const { data: items, error: itemsError } = await supabase
        .from('menu_items')
        .select(`
          *,
          variations (*),
          add_ons (*)
        `)
        .order('sort_order', { ascending: true })
        .order('created_at', { ascending: true });

      if (itemsError) throw itemsError;

      // Auto-fix any items that might have incorrect sort orders
      await autoFixSortOrders(items);

      const formattedItems: MenuItem[] = items?.map(item => {
        // Calculate if discount is currently active
        const now = new Date();
        const discountStart = item.discount_start_date ? new Date(item.discount_start_date) : null;
        const discountEnd = item.discount_end_date ? new Date(item.discount_end_date) : null;
        
        const isDiscountActive = item.discount_active && 
          (!discountStart || now >= discountStart) && 
          (!discountEnd || now <= discountEnd);
        
        // Calculate effective price
        const effectivePrice = isDiscountActive && item.discount_price ? item.discount_price : item.base_price;

        return {
          id: item.id,
          name: item.name,
          description: item.description,
          basePrice: item.base_price,
          category: item.category,
          popular: item.popular,
          available: item.available ?? true,
          image: item.image_url || undefined,
          discountPrice: item.discount_price || undefined,
          discountStartDate: item.discount_start_date || undefined,
          discountEndDate: item.discount_end_date || undefined,
          discountActive: item.discount_active || false,
          effectivePrice,
          isOnDiscount: isDiscountActive,
          sortOrder: item.sort_order,
          variations: item.variations?.map(v => ({
            id: v.id,
            name: v.name,
            price: v.price
          })) || [],
          addOns: item.add_ons?.map(a => ({
            id: a.id,
            name: a.name,
            price: a.price,
            category: a.category
          })) || []
        };
      }) || [];

      setMenuItems(formattedItems);
      setError(null);
    } catch (err) {
      console.error('Error fetching menu items:', err);
      setError(err instanceof Error ? err.message : 'Failed to fetch menu items');
    } finally {
      setLoading(false);
    }
  };

  const addMenuItem = async (item: Omit<MenuItem, 'id'>) => {
    try {
      // Get the highest sort_order to place new item at the end
      const { data: maxSortData } = await supabase
        .from('menu_items')
        .select('sort_order')
        .order('sort_order', { ascending: false })
        .limit(1)
        .single();
      
      // Ensure new items get a sort order that's definitely at the end
      // Use a high base number to avoid conflicts with existing items
      const nextSortOrder = Math.max((maxSortData?.sort_order || 0) + 1, 10000);

      console.log('Adding menu item with data:', {
        name: item.name,
        description: item.description,
        base_price: item.basePrice,
        category: item.category,
        popular: item.popular || false,
        available: item.available ?? true,
        image_url: item.image || null,
        discount_price: item.discountPrice || null,
        discount_start_date: item.discountStartDate || null,
        discount_end_date: item.discountEndDate || null,
        discount_active: item.discountActive || false,
        sort_order: nextSortOrder
      });
      
      console.log('Max sort order found:', maxSortData?.sort_order, 'Next sort order:', nextSortOrder);

      // Insert menu item
      const { data: menuItem, error: itemError } = await supabase
        .from('menu_items')
        .insert({
          name: item.name,
          description: item.description,
          base_price: item.basePrice,
          category: item.category,
          popular: item.popular || false,
          available: item.available ?? true,
          image_url: item.image || null,
          discount_price: item.discountPrice || null,
          discount_start_date: item.discountStartDate || null,
          discount_end_date: item.discountEndDate || null,
          discount_active: item.discountActive || false,
          sort_order: nextSortOrder
        })
        .select()
        .single();

      if (itemError) {
        console.error('Menu item insert error:', itemError);
        throw new Error(`Database error: ${itemError.message} (Code: ${itemError.code})`);
      }

      // Insert variations if any
      if (item.variations && item.variations.length > 0) {
        console.log('Adding variations:', item.variations);
        const { error: variationsError } = await supabase
          .from('variations')
          .insert(
            item.variations.map(v => ({
              menu_item_id: menuItem.id,
              name: v.name,
              price: v.price
            }))
          );

        if (variationsError) {
          console.error('Variations insert error:', variationsError);
          throw new Error(`Variations error: ${variationsError.message} (Code: ${variationsError.code})`);
        }
      }

      // Insert add-ons if any
      if (item.addOns && item.addOns.length > 0) {
        console.log('Adding add-ons:', item.addOns);
        const { error: addOnsError } = await supabase
          .from('add_ons')
          .insert(
            item.addOns.map(a => ({
              menu_item_id: menuItem.id,
              name: a.name,
              price: a.price,
              category: a.category
            }))
          );

        if (addOnsError) {
          console.error('Add-ons insert error:', addOnsError);
          throw new Error(`Add-ons error: ${addOnsError.message} (Code: ${addOnsError.code})`);
        }
      }

      await fetchMenuItems();
      return menuItem;
    } catch (err) {
      console.error('Error adding menu item:', err);
      throw err;
    }
  };

  const updateMenuItem = async (id: string, updates: Partial<MenuItem>) => {
    try {
      // Update menu item
      const { error: itemError } = await supabase
        .from('menu_items')
        .update({
          name: updates.name,
          description: updates.description,
          base_price: updates.basePrice,
          category: updates.category,
          popular: updates.popular,
          available: updates.available,
          image_url: updates.image || null,
          discount_price: updates.discountPrice || null,
          discount_start_date: updates.discountStartDate || null,
          discount_end_date: updates.discountEndDate || null,
          discount_active: updates.discountActive,
          sort_order: updates.sortOrder
        })
        .eq('id', id);

      if (itemError) throw itemError;

      // Delete existing variations and add-ons
      await supabase.from('variations').delete().eq('menu_item_id', id);
      await supabase.from('add_ons').delete().eq('menu_item_id', id);

      // Insert new variations
      if (updates.variations && updates.variations.length > 0) {
        const { error: variationsError } = await supabase
          .from('variations')
          .insert(
            updates.variations.map(v => ({
              menu_item_id: id,
              name: v.name,
              price: v.price
            }))
          );

        if (variationsError) throw variationsError;
      }

      // Insert new add-ons
      if (updates.addOns && updates.addOns.length > 0) {
        const { error: addOnsError } = await supabase
          .from('add_ons')
          .insert(
            updates.addOns.map(a => ({
              menu_item_id: id,
              name: a.name,
              price: a.price,
              category: a.category
            }))
          );

        if (addOnsError) throw addOnsError;
      }

      await fetchMenuItems();
    } catch (err) {
      console.error('Error updating menu item:', err);
      throw err;
    }
  };

  const deleteMenuItem = async (id: string) => {
    try {
      const { error } = await supabase
        .from('menu_items')
        .delete()
        .eq('id', id);

      if (error) throw error;

      await fetchMenuItems();
    } catch (err) {
      console.error('Error deleting menu item:', err);
      throw err;
    }
  };

  const autoFixSortOrders = async (items: any[]) => {
    try {
      // Find items that might have incorrect sort orders (items added after migration)
      // These are items that don't exist in the original migration file
      const migrationItems = [
        'Cheesy Nachos', 'Taco Bites', 'French Fries', 'Mojitos', 'Snack Platter', 'Cheese Quesadilla', 'TORTIZZA', 'Double Cheese Bread', 'Onion Rings', 'Chicken n\' Fish Chips',
        'Green Tossed Salad', 'Firehouse Salad', 'Paradise Salad',
        'Classic Burger', 'Bacon & Mushroom', 'Jalapeno', 'B-L-T', 'Firehouse Paradise', 'Sliders Burger', 'Double Decker',
        'Supreme Cheese', 'Bacon & Cheese', 'Classic Aloha', 'Vegan Lover', 'Ultimate Aloha', 'Pepperoni & Bacon', 'Tuna Jalapeno', 'Gurus Choice', 'Meat Overload', 'Pick of the Bunch',
        'Plain Wings', 'Parmesan Wings', 'Korean Soy Wings', 'Buffalo Wings', 'Trio Wings', 'Medium Tray Wings', 'Large Tray Wings',
        'Clubhouse Sandwich', 'Chicken Sandwich',
        'Pinoy Spaghetti', 'Carbonara', 'Tuna Basil', 'Baked Macaroni', 'Vietnamese Pasta',
        'GOURMET 1', 'GOURMET 2', 'GOURMET 3', 'GOURMET 4', 'GOURMET 5',
        'Batangas Lomi',
        'Soda in Can', 'Soda 1.5L', 'Juice', 'Solo', 'Pitcher', 'Pineapple Juice', 'Bottled Water 500ml',
        'Kapeng Barako', 'Honey Lemon Tea',
        'Java Chip Frappe', 'Mocha Frappe', 'Chocolate Frappe', 'Cookies and Cream Frappe', 'Caramel Macchiato Frappe',
        'San Mig Light in Can', 'Bucket Beer',
        'Liempo Silog', 'Bangus Silog', 'Bacon Silog', 'Ham Silog', 'Tinapa Silog', 'Danggit Silog',
        'Grilled Liempo', 'Gourmet Chops', 'Korean Soy or Buffalo', 'Boneless Bangus', 'Chicken Poppers', 'Fried Chicken', 'Fish Fillet', 'Grilled Chicken', 'Salisbury Steak', 'Mushroom Steak', 'Hungarian or Buffalo', 'Chicken Fillet'
      ];

      // Find items that are not in the migration list (newly added items)
      const newItems = items.filter(item => !migrationItems.includes(item.name));
      
      if (newItems.length > 0) {
        console.log('Found newly added items that need sort order fix:', newItems.map(item => item.name));
        
        // Get the highest sort_order from migration items
        const migrationItemsData = items.filter(item => migrationItems.includes(item.name));
        const maxMigrationSortOrder = Math.max(...migrationItemsData.map(item => item.sort_order || 0), 0);
        
        // Set new items to have sort orders after migration items
        let nextSortOrder = maxMigrationSortOrder + 1000; // Start from 1000+ to be safe
        
        for (const item of newItems) {
          const { error } = await supabase
            .from('menu_items')
            .update({ sort_order: nextSortOrder })
            .eq('id', item.id);
          
          if (error) {
            console.error(`Error fixing sort order for ${item.name}:`, error);
          } else {
            console.log(`Fixed sort order for ${item.name}: ${nextSortOrder}`);
          }
          
          nextSortOrder += 1;
        }
      }
    } catch (err) {
      console.error('Error in auto-fix sort orders:', err);
      // Don't throw error here as it's not critical
    }
  };

  const fixItemSortOrder = async (itemName: string) => {
    try {
      // Get the highest sort_order
      const { data: maxSortData } = await supabase
        .from('menu_items')
        .select('sort_order')
        .order('sort_order', { ascending: false })
        .limit(1)
        .single();
      
      const newSortOrder = Math.max((maxSortData?.sort_order || 0) + 1, 1000);
      
      // Update the specific item's sort order
      const { error } = await supabase
        .from('menu_items')
        .update({ sort_order: newSortOrder })
        .eq('name', itemName);

      if (error) throw error;

      await fetchMenuItems();
    } catch (err) {
      console.error('Error fixing sort order:', err);
      throw err;
    }
  };

  useEffect(() => {
    fetchMenuItems();
  }, []);

  return {
    menuItems,
    loading,
    error,
    addMenuItem,
    updateMenuItem,
    deleteMenuItem,
    fixItemSortOrder,
    refetch: fetchMenuItems
  };
};