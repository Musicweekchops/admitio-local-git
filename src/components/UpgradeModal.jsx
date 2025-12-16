import React from 'react';
import { X, Lock, ChevronRight, Check } from 'lucide-react';
import { PLANES, getPlanesSuperiores, getMensajeUpgrade } from '../lib/planes';

const UpgradeModal = ({ 
  isOpen, 
  onClose, 
  planActual, 
  accion,
  contadorActual = 0 
}) => {
  if (!isOpen) return null;

  const mensaje = getMensajeUpgrade(planActual, accion);
  const planesSuperiores = getPlanesSuperiores(planActual);
  const planRecomendado = mensaje.planRecomendado;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Overlay */}
      <div 
        className="absolute inset-0 bg-black/50 backdrop-blur-sm"
        onClick={onClose}
      />
      
      {/* Modal */}
      <div className="relative bg-white rounded-2xl shadow-2xl max-w-lg w-full overflow-hidden animate-slide-up">
        {/* Header */}
        <div className="bg-gradient-to-r from-violet-600 to-violet-700 px-6 py-5 text-white">
          <button 
            onClick={onClose}
            className="absolute top-4 right-4 text-white/80 hover:text-white"
          >
            <X className="w-5 h-5" />
          </button>
          
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 bg-white/20 rounded-xl flex items-center justify-center">
              <Lock className="w-6 h-6" />
            </div>
            <div>
              <h3 className="font-bold text-xl">{mensaje.titulo}</h3>
              <p className="text-violet-200 text-sm">¡Ya conoces cómo funciona!</p>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="p-6">
          <p className="text-gray-600 mb-6">
            {mensaje.descripcion}
          </p>

          {/* Planes */}
          <div className="space-y-3 mb-6">
            {planesSuperiores.map((plan) => (
              <div 
                key={plan.id}
                className={`p-4 rounded-xl border-2 transition-all cursor-pointer ${
                  plan.id === planRecomendado
                    ? 'border-violet-500 bg-violet-50'
                    : 'border-gray-200 hover:border-gray-300'
                }`}
              >
                <div className="flex items-center justify-between">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-bold text-gray-900">{plan.nombre}</span>
                      {plan.id === planRecomendado && (
                        <span className="text-xs bg-violet-500 text-white px-2 py-0.5 rounded-full">
                          Recomendado
                        </span>
                      )}
                    </div>
                    <div className="text-sm text-gray-500 mt-1">
                      {plan.leads.toLocaleString()} leads • {plan.usuarios} usuarios
                    </div>
                  </div>
                  <div className="text-right">
                    <div className="font-bold text-violet-600">{plan.precioFormateado}</div>
                  </div>
                </div>

                {/* Features del plan */}
                {plan.id === planRecomendado && (
                  <div className="mt-3 pt-3 border-t border-violet-200">
                    <div className="grid grid-cols-2 gap-2 text-sm">
                      {plan.importarCSV && (
                        <div className="flex items-center gap-1 text-gray-600">
                          <Check className="w-4 h-4 text-green-500" />
                          Importar CSV
                        </div>
                      )}
                      {plan.exportarExcel && (
                        <div className="flex items-center gap-1 text-gray-600">
                          <Check className="w-4 h-4 text-green-500" />
                          Exportar Excel
                        </div>
                      )}
                      {plan.duplicados && (
                        <div className="flex items-center gap-1 text-gray-600">
                          <Check className="w-4 h-4 text-green-500" />
                          Duplicados
                        </div>
                      )}
                      {plan.emailsAutomaticos && (
                        <div className="flex items-center gap-1 text-gray-600">
                          <Check className="w-4 h-4 text-green-500" />
                          Emails auto
                        </div>
                      )}
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>

          {/* Actions */}
          <div className="flex gap-3">
            <button
              onClick={onClose}
              className="flex-1 py-3 border border-gray-300 text-gray-700 font-medium rounded-xl hover:bg-gray-50 transition-colors"
            >
              Ahora no
            </button>
            <button
              onClick={() => {
                // TODO: Redirigir a página de planes o contacto
                window.open('mailto:contacto@admitio.cl?subject=Upgrade Plan ' + planRecomendado, '_blank');
                onClose();
              }}
              className="flex-1 py-3 bg-violet-600 text-white font-medium rounded-xl hover:bg-violet-700 transition-colors flex items-center justify-center gap-2"
            >
              Mejorar Plan
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default UpgradeModal;
