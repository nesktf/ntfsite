(local toml (require :toml))
(local {: cat/ : read-file} (require :fs))
(local {: compile-md-content} (require :markdown))

(var comp-date "")

(λ set-comp-date! []
  (set comp-date (os.date "%Y/%m/%d %H:%M (GMT-3)")))

(λ parse-versions [paths]
  (fn parse-markdown [content]
    (icollect [_i elem (ipairs content)]
      (compile-md-content elem)))

  (let [version-meta-content (read-file (cat/ paths.data "version.toml"))
        versions (toml.decode version-meta-content)
        ver-list (icollect [ver detail (pairs versions)]
                   {: ver
                    :timestamp detail.timestamp
                    :title detail.title
                    :changes (parse-markdown detail.changes)
                    :todo (parse-markdown detail.todo)})]
    (table.sort ver-list #(> $1.timestamp $2.timestamp))
    ver-list))

{: parse-versions :comp-date (fn [] comp-date) : set-comp-date!}
