import React from 'react';

const Hero: React.FC = () => {
  return (
    <section className="relative bg-gradient-to-br from-firehouse-off-white to-firehouse-off-white-dark py-20 px-4">
      <div className="max-w-4xl mx-auto text-center">
        <h1 className="text-5xl md:text-6xl font-bold text-firehouse-charcoal mb-6 animate-fade-in">
          Come and Visit
          <span className="block text-firehouse-yellow mt-2 font-extrabold">Firehouse</span>
          <span className="block text-firehouse-charcoal text-3xl md:text-4xl mt-2 font-semibold">Lounge & Resto</span>
        </h1>
        <p className="text-xl text-firehouse-gray mb-8 max-w-2xl mx-auto animate-slide-up">
          Experience the perfect blend of comfort food and vibrant atmosphere. 
          Open daily from 10AM until 10PM.
        </p>
        <div className="flex justify-center space-x-4">
          <a 
            href="#menu"
            className="bg-firehouse-yellow text-firehouse-charcoal px-8 py-3 rounded-full hover:bg-firehouse-yellow-dark transition-all duration-300 transform hover:scale-105 font-bold shadow-lg"
          >
            Explore Menu
          </a>
          <div className="flex items-center space-x-2 text-firehouse-charcoal">
            <span className="text-firehouse-yellow">📞</span>
            <span className="font-semibold">09478910021</span>
          </div>
        </div>
        <div className="mt-6 text-firehouse-gray">
          <p className="font-medium">📍 Banay Banay, Lipa City</p>
        </div>
      </div>
    </section>
  );
};

export default Hero;