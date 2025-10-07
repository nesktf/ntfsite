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

(λ epoch-to-str [epoch]
  (os.date "%Y/%m/%d %H:%M (GMT-3)" (tonumber epoch)))

{: truncate-list : merge-tbls : epoch-to-str}
