# frozen_string_literal: true

SitemapGenerator::Sitemap.default_host = 'https://xn--b1adeqtgm.xn--90ais'
SitemapGenerator::Sitemap.compress = false

SitemapGenerator::Sitemap.create do
  InteriorDoor.find_each do |door|
    add interior_door_path(door),
        lastmod: door.updated_at,
        changefreq: 'weekly',
        priority: 0.8
  end

  EntranceDoor.find_each do |door|
    add entrance_door_path(door),
        lastmod: door.updated_at,
        changefreq: 'weekly',
        priority: 0.8
  end
end
