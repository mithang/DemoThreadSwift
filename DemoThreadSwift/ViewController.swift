// GCD: Grand Central Dispatch
// GCD là một tập hợp thư viện để cải tiến và đơn giản hóa dùng Thread. Chúng ta không còn tạo thread đơn lẽ sau đó start chúng nữa mà chỉ cần, đưa các task(thread) vào trong hàng đợi(queue). Các queue sẽ tự quản lí thread(khởi tạo, chạy và hủy)
//GDP đự trên cơ chết Thread Pool. Đây là cơ chế tối ưu cho việc tạo và hủy thread

//Thread tạo ra nhiều task chạy cùng một lúc

//Dispatch Queues có nhiệm vụ tạo, thực thi và hủy task. Chạy theo cơ chể FIFO(Vào trước, xử lí trước). Có hai loại:
//1.Serial: queue chỉ có duy nhất một thread được chạy tại một thời điểm
//2.Concurrent: Có nhiều thread hơn và có thể chạy song song

//Dispatch Async chạy bắt đồng bộ, không đợi ai, việc ai náy làm
//Dispatch Sync chạy một cách đồng bộ. Dùng khi block thread khi có nhiều thread dùng chung dữ liệu
//Dispatch After: Định thời gian để chạy thread
//DispatchWorkItem bổ sung từ swift 3 không cần viết closure mà chỉ cần dùng class DispatchWorkItem
//Deadlock
//Thread Sanitizer để xem lỗi các thread truy cập cùng lúc
import UIKit
//Chú ý: Cơ chế chạy từ trên xuống dưới theo tuần tự gọi là: blocking FIFO
//Tìm hiểu thêm: https://medium.com/modernnerd-code/grand-central-dispatch-crash-course-for-swift-3-8bf2652c1cb8
//GDC và NSOperation(Operation 4.0) dưới ios 4.0 thì nằm đọc lập và ngược lại. GDC viết bằng Objective-C, nhưng NSOperation được viết thành những đối tượng, kết thừa nó và sau đó dùng nó

class ViewController: UIViewController {

    @IBOutlet weak var lb: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        //Tạo một hàng đợi thread bằng serial, swift 4 không còn cách tạo này
        //let serialQueue = DispatchQueue(label: "mySerialQueue", attributes:[.serial])
        //Chỉ xử lí một thread đâu tiên
        //let normalQueue = DispatchQueue(label: "mySerialQueue")
        
        //Tạo một hàng đợi thread bằng concurent
        let concurrentQueue = DispatchQueue(label: "myConcurrentQueue", attributes:[.concurrent])
        
        //Các queue có sẳn trong hệ thống
        //let mainQueue = DispatchQueue.main
        //let globalQueue = DispatchQueue.global()
        
        print("Đang xử lí...")
        /*
        for i in 0...1000{
            //Nếu dùng serialQueue.async nó sẽ sử lí từ task 1 đến task 999 theo thứ tự
            //concurrentQueue.async: Chạy  không theo thứ tự 0...999
            concurrentQueue.async {
                print(i)
                sleep(1)
            }
        }
        */

        /*
        var count = 0
        for i in 0...1000{
            //Ta thấy có 1000 task chạy bắt đồng bộ và dùng chung biến count, chạy sẽ sai
            //cách khắc phục là concurrentQueue.sync{}, hoac dung @synchronized 
            concurrentQueue.sync {
                count+=1
                print(i)
            }
        }
        print("Count: \(count)")
        */
        
        /*
        concurrentQueue.asyncAfter(deadline: .now()+5, execute: {
            print("Chạy sau 5s")
        })
        */
        
        let task = DispatchWorkItem{
            print("Đã thực thi")
        }
        concurrentQueue.async(execute: task)
        concurrentQueue.asyncAfter(deadline: .now()+5, execute: task)
        
        
        print("Kết thúc")
        
        /*
         DispatchQueue.main.async {
         var sum=0;
         for i in 0...10{
         sum+=i;
         print("sum: \(sum)")
         }
         //Vì nằm trong hàng đợi block nên có thể truy cập nhiều thread, nên cũng có thể update UI
         self.lb.text=String(sum)
         }
         */
        /*
         Hàm thường dùng DispatchQueue để bắt đồng bộ
         let queue = DispatchQueue(label: "queuegroup")
         queue.async{
             //Xử lí dữ liệu internet
             DispatchQueue.main.async{
                //Cập nhật dữ liệu trên UI chính. Chú ý nếu để hàm bên ngoài sẽ bị deadlock vì hàm main chờ hàm main
             }
         }
         */
        //DispathGroup: Cho phép quản lí một nhóm các tác vụ
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "queuegroup")
        //Bắt đầu bắm giờ
        group.enter()
        queue.async {
            for i in 0..<200000{
                print("Xử lý: \(i)")
            }
            group.leave()
        }
        //Nếu thời gian 3s mà xử lí xong 20 thì xuất ra success
        //Nếu trong 3s mà không xử lí hết 20 thì sẽ timeout, tuy hết thời gian nhưng vẫn chạy tiếp tục
        let result = group.wait(timeout: DispatchTime.now()+3)
        print(result)
        
        
        //Bắt đầu xử lí thread pool
        //let queue = OperationQueue()
        //Mỗi lần chỉ xử lí một thread, nếu không có thì nó xử lí cùng một lúc hết tất cả
        //queue.maxConcurrentOperationCount=4
        //for i in 0..<20{
        //    queue.addOperation {
        //        print("Xử lí \(i)")
        //        sleep(100)
        //    }
        //      queue.addOperation(Op(n: i))
        //}
        
        //queue.waitUntilAllOperationsAreFinished()
        //queue.cancelAllOperations()
        
    }
    class Op:Operation{
        var i: Int
        init(n:Int){
            i=n
        }
        override func main() {
            print("Xử lí: \(i)")
            //sleep(100)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}

