import React, { createContext, useContext, useState, useEffect } from 'react'
import { USUARIOS, ROLES } from '../data/mockData'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Verificar sesión guardada
    const savedUser = localStorage.getItem('admitio_user')
    if (savedUser) {
      const userData = JSON.parse(savedUser)
      const fullUser = USUARIOS.find(u => u.id === userData.id)
      if (fullUser && fullUser.activo) {
        setUser(enrichUser(fullUser))
      }
    }
    setLoading(false)
  }, [])

  function enrichUser(userData) {
    const rol = ROLES[userData.rol_id]
    return {
      ...userData,
      rol,
      permisos: rol?.permisos || {}
    }
  }

  function signIn(email, password) {
    const usuario = USUARIOS.find(u => 
      u.email.toLowerCase() === email.toLowerCase() && 
      u.password === password &&
      u.activo
    )
    
    if (usuario) {
      const enrichedUser = enrichUser(usuario)
      setUser(enrichedUser)
      localStorage.setItem('admitio_user', JSON.stringify({ id: usuario.id }))
      return { success: true, user: enrichedUser }
    }
    
    return { success: false, error: 'Credenciales inválidas' }
  }

  function signOut() {
    setUser(null)
    localStorage.removeItem('admitio_user')
  }

  // Helpers de permisos
  const isSuperAdmin = user?.rol_id === 'superadmin'
  const isKeyMaster = user?.rol_id === 'keymaster' || isSuperAdmin
  const isEncargado = user?.rol_id === 'encargado'
  const isAsistente = user?.rol_id === 'asistente'
  const isRector = user?.rol_id === 'rector'
  
  // Permisos específicos
  const canViewAll = user?.permisos?.ver_todos || isSuperAdmin
  const canViewOwn = user?.permisos?.ver_propios
  const canEdit = user?.permisos?.editar || isSuperAdmin
  const canReasignar = user?.permisos?.reasignar || isSuperAdmin
  const canConfig = user?.permisos?.config || isSuperAdmin
  const canManageUsers = user?.permisos?.usuarios || isSuperAdmin
  const canViewReports = user?.permisos?.reportes || isEncargado || isSuperAdmin
  const canManageForms = user?.permisos?.formularios || isSuperAdmin
  const canCreateLeads = user?.permisos?.crear_leads || canEdit
  const canDeleteKeyMaster = user?.permisos?.eliminar_keymaster || isSuperAdmin

  return (
    <AuthContext.Provider value={{
      user,
      loading,
      signIn,
      signOut,
      // Roles
      isSuperAdmin,
      isKeyMaster,
      isEncargado,
      isAsistente,
      isRector,
      // Permisos
      canViewAll,
      canViewOwn,
      canEdit,
      canReasignar,
      canConfig,
      canManageUsers,
      canViewReports,
      canManageForms,
      canCreateLeads,
      canDeleteKeyMaster,
    }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth debe usarse dentro de AuthProvider')
  }
  return context
}
