import React from 'react';
import { ShoppingCart } from 'lucide-react';
import { useSiteSettings } from '../hooks/useSiteSettings';

interface HeaderProps {
  cartItemsCount: number;
  onCartClick: () => void;
  onMenuClick: () => void;
}

const Header: React.FC<HeaderProps> = ({ cartItemsCount, onCartClick, onMenuClick }) => {
  const { siteSettings, loading } = useSiteSettings();

  return (
    <header className="sticky top-0 z-50 bg-firehouse-off-white/95 backdrop-blur-md border-b border-firehouse-yellow/20 shadow-lg">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          <button 
            onClick={onMenuClick}
            className="flex items-center space-x-3 text-firehouse-charcoal hover:text-firehouse-yellow transition-colors duration-200"
          >
            {loading ? (
              <div className="w-10 h-10 bg-firehouse-gray-light rounded-full animate-pulse" />
            ) : (
              <img 
                src={siteSettings?.site_logo || "/logo.png"} 
                alt={siteSettings?.site_name || "Firehouse Lounge & Resto"}
                className="w-10 h-10 rounded-full object-cover shadow-md"
                onError={(e) => {
                  e.currentTarget.src = "/logo.png";
                }}
              />
            )}
            <div className="text-left">
              <h1 className="text-2xl font-bold text-firehouse-charcoal leading-tight">
                {loading ? (
                  <div className="w-32 h-6 bg-firehouse-gray-light rounded animate-pulse" />
                ) : (
                  "Firehouse"
                )}
              </h1>
              <p className="text-sm text-firehouse-gray font-medium -mt-1">
                {loading ? (
                  <div className="w-20 h-4 bg-firehouse-gray-light rounded animate-pulse" />
                ) : (
                  "Lounge & Resto"
                )}
              </p>
            </div>
          </button>

          <div className="flex items-center space-x-2">
            <button 
              onClick={onCartClick}
              className="relative p-3 text-firehouse-charcoal hover:text-firehouse-yellow hover:bg-firehouse-yellow/10 rounded-full transition-all duration-200 border border-firehouse-yellow/20 hover:border-firehouse-yellow"
            >
              <ShoppingCart className="h-6 w-6" />
              {cartItemsCount > 0 && (
                <span className="absolute -top-1 -right-1 bg-firehouse-yellow text-firehouse-charcoal text-xs rounded-full h-5 w-5 flex items-center justify-center animate-bounce-gentle font-bold">
                  {cartItemsCount}
                </span>
              )}
            </button>
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;