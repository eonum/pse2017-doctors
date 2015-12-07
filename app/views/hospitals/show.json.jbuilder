json.hospital do
  json.extract! @hospital, :name, :address1, :address2, :bfs_typo, :canton, :location
end

