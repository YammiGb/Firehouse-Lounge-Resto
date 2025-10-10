import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';

export interface Category {
  id: string;
  name: string;
  icon: string;
  sort_order: number;
  active: boolean;
  created_at: string;
  updated_at: string;
}

export const useCategories = () => {
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchCategories = async () => {
    try {
      setLoading(true);
      
      // First try to fetch from categories table (if it exists)
      const { data: categoriesData, error: categoriesError } = await supabase
        .from('categories')
        .select('*')
        .eq('active', true)
        .order('sort_order', { ascending: true });

      if (categoriesData && categoriesData.length > 0) {
        setCategories(categoriesData);
        setError(null);
        return;
      }

      // If categories table doesn't exist or is empty, get unique categories from menu_items
      const { data: menuItems, error: menuError } = await supabase
        .from('menu_items')
        .select('category')
        .eq('available', true);

      if (menuError) throw menuError;

      // Create categories from unique menu item categories
      const uniqueCategories = [...new Set(menuItems?.map(item => item.category) || [])];
      const categoryMap: { [key: string]: string } = {
        'Starters': '🍽️',
        'Salads': '🥗',
        'Burgers': '🍔',
        'Pizza': '🍕',
        'Wings': '🍗',
        'Sandwiches': '🥪',
        'Pasta': '🍝',
        'Solo Meals': '🍚',
        'Batangas Lomi': '🍜',
        'Frappe': '☕',
        'Cold Beverages': '🥤',
        'Hot Beverages': '☕',
        'Beer': '🍺',
        'Breakfast': '🍳',
        'Rice Meals': '🍛',
        'Group Meals': '👥',
        'Main Dishes': '🍖',
        'Beverages': '🥤',
        'Desserts': '🍰',
        'Appetizers': '🥗',
        'Soups': '🍲',
        'Seafood': '🐟',
        'Chicken': '🐔',
        'Beef': '🥩',
        'Vegetarian': '🥬',
        'Vegan': '🌱'
      };

      const formattedCategories = uniqueCategories.map((category, index) => ({
        id: category.toLowerCase().replace(/\s+/g, '-'),
        name: category,
        icon: categoryMap[category] || '🍽️',
        sort_order: index + 1,
        active: true,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }));

      setCategories(formattedCategories);
      setError(null);
    } catch (err) {
      console.error('Error fetching categories:', err);
      setError(err instanceof Error ? err.message : 'Failed to fetch categories');
    } finally {
      setLoading(false);
    }
  };

  const addCategory = async (category: Omit<Category, 'created_at' | 'updated_at'>) => {
    try {
      const { data, error: insertError } = await supabase
        .from('categories')
        .insert({
          id: category.id,
          name: category.name,
          icon: category.icon,
          sort_order: category.sort_order,
          active: category.active
        })
        .select()
        .single();

      if (insertError) throw insertError;

      await fetchCategories();
      return data;
    } catch (err) {
      console.error('Error adding category:', err);
      throw err;
    }
  };

  const updateCategory = async (id: string, updates: Partial<Category>) => {
    try {
      const { error: updateError } = await supabase
        .from('categories')
        .update({
          name: updates.name,
          icon: updates.icon,
          sort_order: updates.sort_order,
          active: updates.active
        })
        .eq('id', id);

      if (updateError) throw updateError;

      await fetchCategories();
    } catch (err) {
      console.error('Error updating category:', err);
      throw err;
    }
  };

  const deleteCategory = async (id: string) => {
    try {
      // Check if category has menu items
      const { data: menuItems, error: checkError } = await supabase
        .from('menu_items')
        .select('id')
        .eq('category', id)
        .limit(1);

      if (checkError) throw checkError;

      if (menuItems && menuItems.length > 0) {
        throw new Error('Cannot delete category that contains menu items. Please move or delete the items first.');
      }

      const { error: deleteError } = await supabase
        .from('categories')
        .delete()
        .eq('id', id);

      if (deleteError) throw deleteError;

      await fetchCategories();
    } catch (err) {
      console.error('Error deleting category:', err);
      throw err;
    }
  };

  const reorderCategories = async (reorderedCategories: Category[]) => {
    try {
      const updates = reorderedCategories.map((cat, index) => ({
        id: cat.id,
        sort_order: index + 1
      }));

      for (const update of updates) {
        await supabase
          .from('categories')
          .update({ sort_order: update.sort_order })
          .eq('id', update.id);
      }

      await fetchCategories();
    } catch (err) {
      console.error('Error reordering categories:', err);
      throw err;
    }
  };

  useEffect(() => {
    fetchCategories();
  }, []);

  return {
    categories,
    loading,
    error,
    addCategory,
    updateCategory,
    deleteCategory,
    reorderCategories,
    refetch: fetchCategories
  };
};