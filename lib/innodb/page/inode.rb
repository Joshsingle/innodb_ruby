require "innodb/free_list"

class Innodb::Page::Inode < Innodb::Page
  FRAG_ARRAY_N_SLOTS  = 32 # FSP_EXTENT_SIZE / 2
  FRAG_SLOT_SIZE      = 4

  MAGIC_N_VALUE	= 97937874

  def pos_inode_header
    pos_fil_header + size_fil_header + Innodb::FreeList::NODE_SIZE
  end

  def size_inode_header
    (16 + (3 * Innodb::FreeList::BASE_NODE_SIZE) +
      (FRAG_ARRAY_N_SLOTS * FRAG_SLOT_SIZE))
  end

  def uint32_array(size, cursor)
    size.times.map { |n| cursor.get_uint32 }
  end

  def inode_header
    c = cursor(pos_inode_header)
    {
      :fseg_id            => c.get_uint64,
      :not_full_n_used    => c.get_uint32,
      :free               => Innodb::FreeList.get_base_node(c),
      :not_full           => Innodb::FreeList.get_base_node(c),
      :full               => Innodb::FreeList.get_base_node(c),
      :magic_n            => c.get_uint32,
      :frag_array         => uint32_array(FRAG_ARRAY_N_SLOTS, c),
    }
  end

  def dump
    super

    puts
    puts "inode header:"
    pp inode_header
  end
end

Innodb::Page::SPECIALIZED_CLASSES[:INODE] = Innodb::Page::Inode