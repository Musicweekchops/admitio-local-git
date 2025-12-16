// src/lib/supabase.js
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseKey)
```

### 4. Agregar variables de entorno en Render
En tu proyecto de Render → Environment → Add variables:
```
VITE_SUPABASE_URL=https://llceuzahnsfdxxzfknau.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxsY2V1emFobnNmZHh4emZrbmF1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3MTU5MjksImV4cCI6MjA4MTI5MTkyOX0.FfTttCvd6ATUa-RE-2zXn7yGriOv-cbToe_Wjjj-cvw
