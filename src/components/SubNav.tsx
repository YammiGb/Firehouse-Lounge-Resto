import React from 'react';
import { useCategories } from '../hooks/useCategories';

interface SubNavProps {
  selectedCategory: string;
  onCategoryClick: (categoryId: string) => void;
}

const SubNav: React.FC<SubNavProps> = ({ selectedCategory, onCategoryClick }) => {
  const { categories, loading } = useCategories();

  return (
    <div className="sticky top-16 z-40 bg-firehouse-off-white/95 backdrop-blur-md">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center space-x-4 overflow-x-auto py-3 scrollbar-hide">
          {loading ? (
            <div className="flex space-x-4">
              {[1,2,3,4,5].map(i => (
                <div key={i} className="h-8 w-20 bg-firehouse-gray-light rounded animate-pulse" />
              ))}
            </div>
          ) : (
            <>
              <button
                onClick={() => onCategoryClick('all')}
                className={`px-4 py-2 rounded-full text-sm transition-all duration-200 border font-medium ${
                  selectedCategory === 'all'
                    ? 'bg-firehouse-yellow text-firehouse-charcoal border-firehouse-yellow shadow-md'
                    : 'bg-firehouse-off-white text-firehouse-charcoal border-firehouse-yellow/30 hover:border-firehouse-yellow hover:bg-firehouse-yellow/10'
                }`}
              >
                All
              </button>
              {categories.map((c) => (
                <button
                  key={c.id}
                  onClick={() => onCategoryClick(c.id)}
                  className={`px-4 py-2 rounded-full text-sm transition-all duration-200 border flex items-center space-x-2 font-medium ${
                    selectedCategory === c.id
                      ? 'bg-firehouse-yellow text-firehouse-charcoal border-firehouse-yellow shadow-md'
                      : 'bg-firehouse-off-white text-firehouse-charcoal border-firehouse-yellow/30 hover:border-firehouse-yellow hover:bg-firehouse-yellow/10'
                  }`}
                >
                  <span>{c.icon}</span>
                  <span className="whitespace-nowrap">{c.name}</span>
                </button>
              ))}
            </>
          )}
        </div>
      </div>
    </div>
  );
};

export default SubNav;


