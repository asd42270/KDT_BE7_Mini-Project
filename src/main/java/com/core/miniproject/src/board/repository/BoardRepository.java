package com.core.miniproject.src.board.repository;

import com.core.miniproject.src.board.domain.entity.Board;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BoardRepository extends JpaRepository<Board, Long> {
    @Override
    Board save(Board board);

    @Query("""
    select b
    from Board b
    where b.is_deleted=false
""")
    @Override
    List<Board> findAll();

    @Query("""
    select b
    from Board b
    where b.is_deleted=false
    and b.id=?1
""")
    @Override
    Optional<Board> findById(Long boardId);

    @Query("""
    select b
    from Board b
    where b.title like %?1%
    and b.is_deleted=false
""")
    List<Board> findByTitleContains(String title);

    @Query("""
    select b
    from Board b
    where b.content like %?1%
    and b.is_deleted=false
""")
    List<Board> findByContentContains(String content);


}