# traddingview.com.vn — Agent Rules

## 1. Context Loading (BẮT BUỘC)
- Đọc `.agents/identity/master-identity.md` TRƯỚC KHI làm bất kỳ task nào.
- Đọc `.agents/memory/constitution.md` để biết luật dự án.
- KHÔNG suy diễn port, path, credentials từ memory hay dự án khác.

## 2. Project Rules
- Tuân thủ constitution.md — đây là "Source of Law".
- **Docker Protocol**: Chạy app trong container. Bind ports tới 127.0.0.1. Dùng multi-stage builds cho production.
- **SEO**: Tuân thủ checklist SEO trong `.agents/knowledge/seo_standards.md` nếu có.
- Mọi task ảnh hưởng > 3 files → phải tạo implementation_plan.md trước.
- KHÔNG chạy destructive commands mà không có user confirm.

## 3. Code Style
- Phản hồi developer bằng Tiếng Việt.
- PowerShell 5.1+, ngăn cách lệnh bằng dấu `;`.
- KHÔNG hard-code URLs, Tokens, Keys — dùng ENV vars (.env).

## 4. Workflow
- Sử dụng SDD flow: Specify → Plan → Tasks → Implement.
- Sau khi hoàn thành task, cập nhật trạng thái trong tasks.md.

## 5. Memorization Protocol (Quy tắc tự cập nhật)
Khi User yêu cầu "ghi nhớ", "cập nhật" quy tắc, tiêu chuẩn hoặc bản phân tích, BẮT BUỘC phân loại và lưu vào đúng vị trí:
- **Tiêu chuẩn Code / Tech Stack / Quy định nghiệp vụ**: Ghi vào `.agents/memory/constitution.md`.
- **Hành vi / Agent Rules đặc thù dự án**: Cập nhật thẳng vào `.agents/AGENTS.md`.
- **Bản phân tích dài hạn (SEO Plan, System Architecture, Spec)**: Tạo file markdown tại `.agents/specs/` (VD: `.agents/specs/seo-plan.md`).
- **Scripts / Tự động hóa**: Tạo Skill mới tại `.agents/skills/`.
TUYỆT ĐỐI KHÔNG lưu tài liệu, rule ra ngoài cấu trúc `.agents/`.
