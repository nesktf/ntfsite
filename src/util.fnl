(fn truncate-list [list n]
  (let [len (length list)
        out []]
    (if (>= n len)
        list
        (do
          (for [i 1 n]
            (table.insert out (. list i)))
          out))))

(fn merge-tbls [...]
  (let [out {}
        tbls [...]]
    (each [_ tbl (ipairs tbls)]
      (each [k v (pairs tbl)]
        (tset out k v)))
    out))

{: truncate-list : merge-tbls}
