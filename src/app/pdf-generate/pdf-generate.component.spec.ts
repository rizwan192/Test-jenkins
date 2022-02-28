import { ComponentFixture, TestBed } from '@angular/core/testing';

import { PdfGenerateComponent } from './pdf-generate.component';

describe('PdfGenerateComponent', () => {
  let component: PdfGenerateComponent;
  let fixture: ComponentFixture<PdfGenerateComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ PdfGenerateComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(PdfGenerateComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
