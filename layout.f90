module layout
  !-----------------------------------------
  ! contains routine to load layout file and sets the layout variables
  ! gets process id and total process 
  !------------------------------
  use mpi
  use global, only: CONFIG_FILE_UNIT, RESNORM_FILE_UNIT, FILE_NAME_LENGTH, &
       STRING_BUFFER_LENGTH, INTERPOLANT_NAME_LENGTH
  use utils, only: dmsg, DEBUG_LEVEL
  implicit none
  
  ! process layout
  integer,public :: total_process,total_entries,process_id, &
       imin_id,imax_id,jmin_id,jmax_id,kmin_id,kmax_id
  character(len=FILE_NAME_LENGTH) :: grid_file_buf
  character(len=FILE_NAME_LENGTH) :: bc_file
  public :: get_next_token_parallel
  public :: read_layout_file
  public :: get_process_data

contains


  subroutine get_process_data()
  implicit none
    ! finds and sets process data
    integer :: ierr
    call MPI_COMM_RANK(MPI_COMM_WORLD,process_id,ierr)
    call MPI_COMM_SIZE(MPI_COMM_WORLD,total_process,ierr)

  end subroutine get_process_data

  subroutine get_next_token_parallel(buf)
    !-----------------------------------------------------------
    ! Extract the next token from the layout file
    !
    ! Each token is on a separate line.
    ! There may be multiple comments (lines beginning with #) 
    ! and blank lines in between.
    ! The purpose of this subroutine is to ignore all these 
    ! lines and return the next "useful" line.
    !-----------------------------------------------------------

    implicit none
    character(len=STRING_BUFFER_LENGTH), intent(out) :: buf
    integer :: ios

    do
       read(CONFIG_FILE_UNIT, '(A)', iostat=ios) buf
       if (ios /= 0) then
          print *, 'Error while reading config file.'
          print *, 'Current buffer length is set to: ', &
               STRING_BUFFER_LENGTH
          stop
       end if
       if (index(buf, '#') == 1) then
          ! The current line begins with a hash
          ! Ignore it
          continue
       else if (len_trim(buf) == 0) then
          ! The current line is empty
          ! Ignore it
          continue
       else
          ! A new token has been found
          ! Break out
          exit
       end if
    end do
    call dmsg(0, 'solver', 'get_next_token', 'Returning: ' // trim(buf))

  end subroutine get_next_token_parallel


  subroutine read_layout_file(process_id)
    implicit none
    character(len=FILE_NAME_LENGTH) :: layout_file = "layout.md"
    character(len=STRING_BUFFER_LENGTH) :: buf
    integer,intent(in)::process_id
    integer :: i,buf_id 
    call dmsg(1, 'layout', 'read_layout_file')

    open(CONFIG_FILE_UNIT, file=layout_file)

    ! Read the parameters from the file
    call get_next_token_parallel(buf)
    read(buf,*)total_process
    call get_next_token_parallel(buf)
    read(buf,*)total_entries
    i = 0
    !print *, process_id
    call get_next_token_parallel(buf)
    do while(i < process_id)
          call get_next_token_parallel(buf)
       i = i+1
    end do
    read(buf,*) buf_id, grid_file_buf, bc_file, imin_id, imax_id, jmin_id,jmax_id,kmin_id,kmax_id
    !print *, process_id ,grid_file_buf ,  bc_file, imin_id, imax_id, jmin_id,jmax_id,kmin_id,kmax_id
  end subroutine read_layout_file


end module layout
