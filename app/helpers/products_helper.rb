# frozen_string_literal: true

module ProductsHelper
  def compact_pagination_pages(current_page, total_pages)
    return [] if total_pages <= 0

    pages = pagination_window(current_page, total_pages)
    build_compact_pages(pages)
  end

  def catalog_product_path(product, **)
    case product
    when EntranceDoor
      entrance_door_path(product, **)
    when InteriorDoor
      interior_door_path(product, **)
    when SystemDoor
      system_door_path(product, **)
    else
      raise ArgumentError, "Unknown catalog product: #{product.class.name}"
    end
  end

  private

  def pagination_window(current_page, total_pages)
    pages = [1, total_pages]

    ((current_page - 1)..(current_page + 1)).each do |page|
      pages << page if page.between?(1, total_pages)
    end

    pages.uniq.sort
  end

  def build_compact_pages(pages)
    pages.each_with_object([]) do |page, compact_pages|
      append_gap_marker(compact_pages, page)
      compact_pages << page
    end
  end

  def append_gap_marker(compact_pages, page)
    return if compact_pages.empty?

    gap = page - compact_pages.last

    if gap == 2
      compact_pages << (page - 1)
    elsif gap > 2
      compact_pages << :ellipsis
    end
  end
end
