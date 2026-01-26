export const sidebarStore = {
  isOpen: false,
  scrollbarWidth: 0,
  
  open() {
    this.isOpen = true;
    const scrollbarWidth = window.innerWidth - document.documentElement.clientWidth;
    this.scrollbarWidth = scrollbarWidth;
    document.documentElement.style.overflow = 'hidden';
    document.documentElement.style.paddingRight = scrollbarWidth > 0 ? `${scrollbarWidth}px` : '';
  },
  
  close() {
    this.isOpen = false;
    document.documentElement.style.overflow = '';
    document.documentElement.style.paddingRight = '';
  },
  
  toggle() {
    this.isOpen ? this.close() : this.open();
  }
};
