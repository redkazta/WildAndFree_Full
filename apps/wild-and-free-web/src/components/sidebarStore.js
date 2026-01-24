export const sidebarStore = {
  isOpen: false,
  
  open() {
    this.isOpen = true;
    document.documentElement.style.overflow = 'hidden';
  },
  
  close() {
    this.isOpen = false;
    document.documentElement.style.overflow = '';
  },
  
  toggle() {
    this.isOpen ? this.close() : this.open();
  }
};