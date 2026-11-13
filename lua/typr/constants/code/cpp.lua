-- C++ snippets for the code mode
-- each snippet is typed line by line; blank lines are skipped and lines
-- longer than the typing area are dropped, so keep them within 76 columns.
-- they are fragments for typing practice: names they use may be undefined
return {
  ----------------------------- basics -----------------------------

  [=[
#include <algorithm>
#include <string>
#include <vector>]=],

  [=[
int main(int argc, char* argv[]) {
    std::vector<std::string> args(argv + 1, argv + argc);
    for (const auto& arg : args) {
        std::cout << arg << '\n';
    }
    return 0;
}]=],

  [=[
int main() {
    std::ios::sync_with_stdio(false);
    std::cin.tie(nullptr);
    int t;
    std::cin >> t;
    while (t--) solve();
}]=],

  [=[
int n;
std::cin >> n;
std::vector<int> a(n);
for (auto& x : a) std::cin >> x;
std::cout << *std::max_element(a.begin(), a.end()) << '\n';]=],

  [=[
for (int i = 1; i <= 100; ++i) {
    if (i % 15 == 0) std::cout << "FizzBuzz\n";
    else if (i % 3 == 0) std::cout << "Fizz\n";
    else if (i % 5 == 0) std::cout << "Buzz\n";
    else std::cout << i << '\n';
}]=],

  [=[
int choice = 0;
do {
    print_menu();
    std::cin >> choice;
    handle(choice);
} while (choice != 0);]=],

  [=[
for (int i = 1; i < argc; ++i) {
    std::string_view arg = argv[i];
    if (arg == "-v" || arg == "--verbose") {
        verbose = true;
    } else if (arg.starts_with("--out=")) {
        output = arg.substr(6);
    } else {
        inputs.emplace_back(arg);
    }
}]=],

  [=[
int port = std::stoi(port_str);
double ratio = std::stod("0.75");
std::string id = "user-" + std::to_string(user_id);]=],

  [=[
double ratio = static_cast<double>(hits) / static_cast<double>(total);
int percent = static_cast<int>(std::round(ratio * 100.0));]=],

  [=[
for (std::size_t i = 0; auto& row : table) {
    std::cout << i++ << ": " << row.name << '\n';
}]=],

  ------------------------ classes and objects ------------------------

  [=[
class Shape {
public:
    virtual ~Shape() = default;
    virtual double area() const = 0;
    virtual void draw(Canvas& canvas) const = 0;
};]=],

  [=[
class Circle : public Shape {
public:
    explicit Circle(double radius) : radius_(radius) {}
    double area() const override { return 3.14159 * radius_ * radius_; }

private:
    double radius_;
};]=],

  [=[
struct Point {
    int x = 0;
    int y = 0;
    bool operator==(const Point&) const = default;
};]=],

  [=[
struct Animal {
    virtual ~Animal() = default;
    virtual std::string sound() const { return "..."; }
};

struct Dog final : Animal {
    std::string sound() const override { return "woof"; }
};]=],

  [=[
std::vector<std::unique_ptr<Shape>> shapes;
shapes.push_back(std::make_unique<Circle>(2.0));
shapes.push_back(std::make_unique<Rect>(3.0, 4.0));
double total = 0.0;
for (const auto& s : shapes) total += s->area();]=],

  [=[
if (auto* button = dynamic_cast<Button*>(widget)) {
    button->on_click();
} else if (auto* slider = dynamic_cast<Slider*>(widget)) {
    slider->set_value(0.5f);
}]=],

  [=[
class File {
public:
    explicit File(const char* path) : fp_(std::fopen(path, "rb")) {
        if (!fp_) throw std::system_error(errno, std::generic_category());
    }
    ~File() { if (fp_) std::fclose(fp_); }
    File(const File&) = delete;
    File& operator=(const File&) = delete;

private:
    std::FILE* fp_;
};]=],

  [=[
Buffer(Buffer&& other) noexcept
    : data_(std::exchange(other.data_, nullptr)),
      size_(std::exchange(other.size_, 0)) {}

Buffer& operator=(Buffer&& other) noexcept {
    std::swap(data_, other.data_);
    std::swap(size_, other.size_);
    return *this;
}]=],

  [=[
void Widget::swap(Widget& other) noexcept {
    using std::swap;
    swap(name_, other.name_);
    swap(children_, other.children_);
}]=],

  [=[
class Timer {
public:
    Timer() : Timer("default") {}
    explicit Timer(std::string name)
        : name_(std::move(name)), start_(Clock::now()) {}

private:
    using Clock = std::chrono::steady_clock;
    std::string name_;
    Clock::time_point start_;
};]=],

  [=[
class Parser {
public:
    Parser();
    ~Parser();
    Ast parse(std::string_view source);

private:
    struct Impl;
    std::unique_ptr<Impl> impl_;
};]=],

  [=[
Logger& Logger::instance() {
    static Logger logger;
    return logger;
}]=],

  [=[
class Money {
public:
    explicit Money(long cents) : cents_(cents) {}
    friend Money operator+(Money a, Money b) {
        return Money(a.cents_ + b.cents_);
    }
    friend bool operator<(Money a, Money b) { return a.cents_ < b.cents_; }

private:
    long cents_;
};]=],

  [=[
void Account::withdraw(long amount) {
    if (amount <= 0) {
        throw std::invalid_argument("amount must be positive");
    }
    if (amount > balance_) {
        throw InsufficientFunds(balance_, amount);
    }
    balance_ -= amount;
    history_.push_back({TxKind::Withdraw, amount});
}]=],

  [=[
WindowConfig config{
    .title = "Editor",
    .width = 1280,
    .height = 720,
    .vsync = true,
};
auto window = create_window(config);]=],

  [=[
struct Settings {
    std::optional<int> max_fps;
    std::optional<std::string> theme;
};
int fps = settings.max_fps.value_or(60);
if (settings.theme) apply_theme(*settings.theme);]=],

  [=[
class EventBus {
public:
    using Handler = std::function<void(const Event&)>;
    void subscribe(EventType type, Handler h) {
        handlers_[type].push_back(std::move(h));
    }
    void publish(const Event& e) {
        for (auto& h : handlers_[e.type]) h(e);
    }

private:
    std::unordered_map<EventType, std::vector<Handler>> handlers_;
};]=],

  [=[
template <typename Derived>
struct Counter {
    static inline int created = 0;
    Counter() { ++created; }
};

class Widget : public Counter<Widget> {};]=],

  ------------------------ operators ------------------------

  [=[
struct Vec2 {
    float x, y;
    Vec2 operator+(Vec2 o) const { return {x + o.x, y + o.y}; }
    Vec2 operator*(float s) const { return {x * s, y * s}; }
    Vec2& operator+=(Vec2 o) { x += o.x; y += o.y; return *this; }
};]=],

  [=[
std::ostream& operator<<(std::ostream& os, const Vec2& v) {
    return os << '(' << v.x << ", " << v.y << ')';
}]=],

  [=[
struct Version {
    int major, minor, patch;
    auto operator<=>(const Version&) const = default;
};]=],

  [=[
struct PointHash {
    std::size_t operator()(const Point& p) const noexcept {
        return std::hash<int>{}(p.x) ^ (std::hash<int>{}(p.y) << 1);
    }
};
std::unordered_set<Point, PointHash> visited;]=],

  ------------------------ templates ------------------------

  [=[
template <typename T>
T clamp(const T& value, const T& lo, const T& hi) {
    return value < lo ? lo : (hi < value ? hi : value);
}]=],

  [=[
template <typename... Args>
void log(std::format_string<Args...> fmt, Args&&... args) {
    std::cout << std::format(fmt, std::forward<Args>(args)...) << '\n';
}]=],

  [=[
template <typename... Ts>
auto sum(Ts... values) {
    return (values + ... + 0);
}

template <typename... Ts>
void print_all(const Ts&... args) {
    ((std::cout << args << ' '), ...);
}]=],

  [=[
template <typename T>
concept Numeric = std::integral<T> || std::floating_point<T>;

template <Numeric T>
T square(T x) { return x * x; }]=],

  [=[
template <typename T>
concept Drawable = requires(const T& t, Canvas& c) {
    { t.draw(c) } -> std::same_as<void>;
    { t.bounds() } -> std::convertible_to<Rect>;
};]=],

  [=[
template <typename T>
    requires std::copyable<T>
class Cache {
public:
    void put(const std::string& key, const T& value) { data_[key] = value; }
    std::optional<T> get(const std::string& key) const {
        auto it = data_.find(key);
        if (it == data_.end()) return std::nullopt;
        return it->second;
    }

private:
    std::unordered_map<std::string, T> data_;
};]=],

  [=[
template <typename T,
          typename = std::enable_if_t<std::is_integral_v<T>>>
bool is_even(T n) {
    return n % 2 == 0;
}]=],

  [=[
template <typename T>
void serialize(std::ostream& os, const T& value) {
    if constexpr (std::is_arithmetic_v<T>) {
        os.write(reinterpret_cast<const char*>(&value), sizeof(T));
    } else {
        value.serialize(os);
    }
}]=],

  [=[
template <typename T>
struct TypeName { static constexpr const char* value = "unknown"; };

template <>
struct TypeName<int> { static constexpr const char* value = "int"; };]=],

  [=[
template <typename T>
class Stack {
public:
    void push(T value) { items_.push_back(std::move(value)); }
    T pop() {
        T top = std::move(items_.back());
        items_.pop_back();
        return top;
    }
    bool empty() const { return items_.empty(); }

private:
    std::vector<T> items_;
};]=],

  [=[
template <typename T, std::size_t N>
class RingBuffer {
public:
    void push(const T& value) {
        data_[head_] = value;
        head_ = (head_ + 1) % N;
        size_ = std::min(size_ + 1, N);
    }

private:
    std::array<T, N> data_{};
    std::size_t head_ = 0, size_ = 0;
};]=],

  [=[
template <class... Ts>
struct overloaded : Ts... { using Ts::operator()...; };

std::visit(overloaded{
    [](int i) { std::cout << "int " << i; },
    [](const std::string& s) { std::cout << "str " << s; },
}, value);]=],

  [=[
template <typename F>
struct ScopeExit {
    F fn;
    ~ScopeExit() { fn(); }
};
template <typename F> ScopeExit(F) -> ScopeExit<F>;

ScopeExit cleanup{[&] { std::fclose(fp); }};]=],

  ------------------------ compile time ------------------------

  [=[
constexpr unsigned long long factorial(unsigned n) {
    return n <= 1 ? 1 : n * factorial(n - 1);
}
static_assert(factorial(5) == 120);]=],

  [=[
template <typename T, std::size_t N>
constexpr std::size_t array_size(const T (&)[N]) noexcept {
    return N;
}
static_assert(array_size("abc") == 4);]=],

  [=[
consteval int kib(int n) { return n * 1024; }
constexpr int kBufferSize = kib(64);
std::array<char, kBufferSize> buffer{};]=],

  [=[
enum class Color : std::uint8_t { Red, Green, Blue };
static_assert(sizeof(Color) == 1, "Color must fit in a byte");]=],

  [=[
inline constexpr std::array kWeekdays{
    "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun",
};]=],

  [=[
constexpr std::string_view to_string(Level level) {
    switch (level) {
        case Level::Debug: return "debug";
        case Level::Info:  return "info";
        case Level::Warn:  return "warn";
        case Level::Error: return "error";
    }
    return "unknown";
}]=],

  ------------------------ containers ------------------------

  [=[
std::unordered_map<std::string, int> counts;
for (const auto& word : words) {
    ++counts[word];
}]=],

  [=[
if (auto it = cache.find(key); it != cache.end()) {
    return it->second;
}
auto value = compute(key);
cache.emplace(key, value);
return value;]=],

  [=[
std::map<int, std::string> events;
events[1200] = "lunch";
events[900] = "standup";
auto next = events.lower_bound(now);
if (next != events.end()) notify(next->second);]=],

  [=[
std::set<std::string> seen;
for (const auto& word : words) {
    if (!seen.insert(word).second) {
        std::cout << "duplicate: " << word << '\n';
    }
}]=],

  [=[
const std::unordered_map<int, std::string_view> kStatusText{
    {200, "OK"},
    {404, "Not Found"},
    {500, "Internal Server Error"},
};]=],

  [=[
std::tuple<int, std::string, double> row{1, "alice", 93.5};
auto [id, name, score] = row;
std::get<2>(row) += 1.0;]=],

  [=[
for (auto& [name, score] : scoreboard) {
    if (score >= threshold && !name.starts_with("bot_")) {
        winners.push_back(name);
    }
}]=],

  [=[
std::vector<Particle> particles;
particles.reserve(count);
for (int i = 0; i < count; ++i) {
    particles.emplace_back(random_position(), random_velocity());
}]=],

  [=[
std::vector<std::vector<int>> paths(rows, std::vector<int>(cols, 1));
for (int r = 1; r < rows; ++r) {
    for (int c = 1; c < cols; ++c) {
        paths[r][c] = paths[r - 1][c] + paths[r][c - 1];
    }
}]=],

  [=[
std::bitset<64> flags;
flags.set(3);
flags.flip(7);
if (flags.test(3) && flags.count() == 2) {
    std::cout << flags.to_string() << '\n';
}]=],

  [=[
std::array<int, 26> freq{};
for (char c : word) {
    if (c >= 'a' && c <= 'z') ++freq[c - 'a'];
}]=],

  [=[
void normalize(std::span<float> values) {
    float max = *std::max_element(values.begin(), values.end());
    if (max == 0.0f) return;
    for (float& v : values) v /= max;
}]=],

  [=[
std::priority_queue<int, std::vector<int>, std::greater<int>> heap;
for (int x : nums) {
    heap.push(x);
    if (heap.size() > k) heap.pop();
}
return heap.top();]=],

  [=[
std::deque<int> window;
for (int i = 0; i < static_cast<int>(nums.size()); ++i) {
    while (!window.empty() && nums[window.back()] <= nums[i]) {
        window.pop_back();
    }
    window.push_back(i);
    if (window.front() <= i - k) window.pop_front();
}]=],

  [=[
int LRUCache::get(int key) {
    auto it = index_.find(key);
    if (it == index_.end()) return -1;
    order_.splice(order_.begin(), order_, it->second);
    return it->second->second;
}]=],

  ------------------------ algorithms ------------------------

  [=[
std::sort(items.begin(), items.end(), [](const Item& a, const Item& b) {
    return a.priority > b.priority;
});]=],

  [=[
auto it = std::find_if(users.begin(), users.end(),
                       [&](const User& u) { return u.id == target_id; });
if (it != users.end()) {
    it->last_seen = now;
}]=],

  [=[
items.erase(std::remove_if(items.begin(), items.end(),
                           [](const Item& i) { return i.expired; }),
            items.end());]=],

  [=[
std::erase_if(sessions, [&](const auto& s) {
    return now - s.last_active > timeout;
});]=],

  [=[
std::sort(ids.begin(), ids.end());
ids.erase(std::unique(ids.begin(), ids.end()), ids.end());]=],

  [=[
auto total = std::accumulate(prices.begin(), prices.end(), 0.0);
auto average = prices.empty() ? 0.0 : total / prices.size();
std::printf("avg: %.2f (n=%zu)\n", average, prices.size());]=],

  [=[
bool all_valid = std::all_of(forms.begin(), forms.end(),
                             [](const Form& f) { return f.valid(); });
auto pending = std::count_if(jobs.begin(), jobs.end(),
                             [](const Job& j) { return !j.done; });]=],

  [=[
auto median_it = values.begin() + values.size() / 2;
std::nth_element(values.begin(), median_it, values.end());
double median = *median_it;]=],

  [=[
auto [lo, hi] = std::minmax_element(temps.begin(), temps.end());
std::cout << "range: " << *lo << " to " << *hi << '\n';]=],

  [=[
auto [first, last] = std::equal_range(sorted.begin(), sorted.end(), key);
std::size_t occurrences = std::distance(first, last);]=],

  [=[
std::vector<int> squares(10);
std::generate(squares.begin(), squares.end(), [n = 0]() mutable {
    ++n;
    return n * n;
});]=],

  [=[
std::copy(values.begin(), values.end(),
          std::ostream_iterator<int>(std::cout, ", "));
std::cout << '\n';]=],

  [=[
std::vector<Order> late;
std::copy_if(orders.begin(), orders.end(), std::back_inserter(late),
             [&](const Order& o) { return o.due < today; });]=],

  [=[
std::sort(students.begin(), students.end(),
          [](const Student& a, const Student& b) {
              return std::tie(b.grade, a.name) < std::tie(a.grade, b.name);
          });]=],

  [=[
using Entry = std::pair<std::string, int>;
std::vector<Entry> ranking(counts.begin(), counts.end());
std::sort(ranking.begin(), ranking.end(),
          [](const auto& a, const auto& b) { return a.second > b.second; });]=],

  [=[
void rotate_right(std::vector<int>& v, int k) {
    k %= static_cast<int>(v.size());
    std::rotate(v.rbegin(), v.rbegin() + k, v.rend());
}]=],

  [=[
std::vector<int> deck(52);
std::iota(deck.begin(), deck.end(), 0);
std::mt19937 rng{std::random_device{}()};
std::shuffle(deck.begin(), deck.end(), rng);]=],

  ------------------------ ranges ------------------------

  [=[
auto evens = numbers
    | std::views::filter([](int n) { return n % 2 == 0; })
    | std::views::transform([](int n) { return n * n; });
for (int n : evens) std::cout << n << ' ';]=],

  [=[
std::ranges::sort(players, std::greater{}, &Player::score);
auto top = std::ranges::find_if(players, [](const Player& p) {
    return p.online;
});]=],

  [=[
for (int i : std::views::iota(0, 10) | std::views::reverse) {
    std::cout << i << ' ';
}]=],

  ------------------------ strings ------------------------

  [=[
std::vector<std::string> split(std::string_view s, char delim) {
    std::vector<std::string> parts;
    std::size_t start = 0, end;
    while ((end = s.find(delim, start)) != std::string_view::npos) {
        parts.emplace_back(s.substr(start, end - start));
        start = end + 1;
    }
    parts.emplace_back(s.substr(start));
    return parts;
}]=],

  [=[
std::string_view trim(std::string_view s) {
    auto first = s.find_first_not_of(" \t\n");
    if (first == std::string_view::npos) return {};
    auto last = s.find_last_not_of(" \t\n");
    return s.substr(first, last - first + 1);
}]=],

  [=[
std::string join(const std::vector<std::string>& parts,
                 std::string_view sep) {
    std::string out;
    for (std::size_t i = 0; i < parts.size(); ++i) {
        if (i > 0) out += sep;
        out += parts[i];
    }
    return out;
}]=],

  [=[
void replace_all(std::string& s, std::string_view from,
                 std::string_view to) {
    std::size_t pos = 0;
    while ((pos = s.find(from, pos)) != std::string::npos) {
        s.replace(pos, from.size(), to);
        pos += to.size();
    }
}]=],

  [=[
std::transform(name.begin(), name.end(), name.begin(),
               [](unsigned char c) { return std::tolower(c); });]=],

  [=[
bool is_palindrome(std::string_view s) {
    for (std::size_t i = 0, j = s.size(); i + 1 < j; ++i, --j) {
        if (s[i] != s[j - 1]) return false;
    }
    return true;
}]=],

  [=[
std::string_view extension(std::string_view filename) {
    auto dot = filename.rfind('.');
    if (dot == std::string_view::npos || dot == 0) return {};
    return filename.substr(dot + 1);
}]=],

  [=[
std::string escape(std::string_view s) {
    std::string out;
    out.reserve(s.size());
    for (char c : s) {
        switch (c) {
            case '"':  out += "\\\""; break;
            case '\\': out += "\\\\"; break;
            case '\n': out += "\\n"; break;
            default:   out += c;
        }
    }
    return out;
}]=],

  [=[
if (line.starts_with("GET ")) {
    auto path = line.substr(4, line.find(' ', 4) - 4);
    serve(path);
} else if (line.starts_with("POST ")) {
    handle_post(line);
}]=],

  [=[
std::string_view rest = input;
while (!rest.empty() && rest.front() == ' ') {
    rest.remove_prefix(1);
}]=],

  [=[
std::ostringstream out;
out << std::fixed << std::setprecision(3);
out << "x=" << pos.x << ", y=" << pos.y;
return out.str();]=],

  [=[
std::istringstream in(line);
std::string cmd;
int count = 0;
if (!(in >> cmd >> count)) {
    throw std::invalid_argument("bad command: " + line);
}]=],

  [=[
std::string label = std::format("{:<10} {:>6.2f}%", name, percent);
std::puts(label.c_str());]=],

  ------------------------ optional, variant, errors ------------------------

  [=[
std::optional<int> parse_int(std::string_view text) {
    int value = 0;
    const char* end = text.data() + text.size();
    auto [p, ec] = std::from_chars(text.data(), end, value);
    if (ec != std::errc{}) return std::nullopt;
    return value;
}]=],

  [=[
std::optional<User> find_user(int id);

auto name = find_user(42)
    .transform([](const User& u) { return u.name; })
    .value_or("guest");]=],

  [=[
std::expected<Config, std::string> parse(std::string_view src) {
    if (src.empty()) return std::unexpected("empty input");
    Config cfg;
    cfg.raw = std::string(src);
    return cfg;
}]=],

  [=[
using Value = std::variant<int, double, std::string>;
std::visit([](const auto& v) {
    std::cout << v << '\n';
}, value);]=],

  [=[
try {
    auto config = load_config(path);
    apply(config);
} catch (const std::exception& e) {
    std::cerr << "error: " << e.what() << std::endl;
    return EXIT_FAILURE;
}]=],

  [=[
class ParseError : public std::runtime_error {
public:
    ParseError(const std::string& msg, int line)
        : std::runtime_error(msg), line_(line) {}
    int line() const noexcept { return line_; }

private:
    int line_;
};]=],

  ------------------------ memory ------------------------

  [=[
auto ptr = std::make_unique<Buffer>(1024);
std::shared_ptr<Logger> logger = std::make_shared<FileLogger>("app.log");
logger->info("buffer size: {}", ptr->size());]=],

  [=[
if (auto target = weak_target.lock()) {
    target->take_damage(10);
} else {
    retarget();
}]=],

  [=[
class Session : public std::enable_shared_from_this<Session> {
public:
    void start() {
        auto self = shared_from_this();
        socket_.async_read([self](auto data) { self->on_read(data); });
    }
};]=],

  [=[
struct FreeDeleter {
    void operator()(void* p) const noexcept { std::free(p); }
};
using MallocPtr = std::unique_ptr<char, FreeDeleter>;
MallocPtr buf(static_cast<char*>(std::malloc(size)));]=],

  [=[
template <typename T>
struct Node {
    T value;
    std::unique_ptr<Node> next;
};]=],

  [=[
void push_front(T value) {
    auto node = std::make_unique<Node<T>>(std::move(value));
    node->next = std::move(head_);
    head_ = std::move(node);
    ++size_;
}]=],

  [=[
float f = 1.5f;
std::uint32_t bits;
std::memcpy(&bits, &f, sizeof bits);
std::printf("%08x\n", bits);
auto same = std::bit_cast<std::uint32_t>(f);]=],

  ------------------------ lambdas and functions ------------------------

  [=[
auto make_counter() {
    return [count = 0]() mutable { return ++count; };
}
auto next_id = make_counter();
int a = next_id();
int b = next_id();]=],

  [=[
auto fib = [](auto&& self, int n) -> long long {
    return n < 2 ? n : self(self, n - 1) + self(self, n - 2);
};
std::cout << fib(fib, 40) << '\n';]=],

  [=[
void retry(int attempts, const std::function<bool()>& action) {
    for (int i = 0; i < attempts; ++i) {
        if (action()) return;
        std::this_thread::sleep_for(std::chrono::milliseconds(100 << i));
    }
    throw std::runtime_error("all retries failed");
}]=],

  ------------------------ concurrency ------------------------

  [=[
std::lock_guard<std::mutex> lock(mutex_);
queue_.push(std::move(task));
cv_.notify_one();]=],

  [=[
std::vector<std::thread> workers;
for (int i = 0; i < num_threads; ++i) {
    workers.emplace_back([this, i] { run_worker(i); });
}
for (auto& t : workers) t.join();]=],

  [=[
void ThreadPool::worker() {
    while (true) {
        std::function<void()> task;
        {
            std::unique_lock lock(mutex_);
            cv_.wait(lock, [this] { return stop_ || !tasks_.empty(); });
            if (stop_ && tasks_.empty()) return;
            task = std::move(tasks_.front());
            tasks_.pop();
        }
        task();
    }
}]=],

  [=[
auto future = std::async(std::launch::async, [&] {
    return load_texture("grass.png");
});
// ... do other work ...
Texture tex = future.get();]=],

  [=[
std::atomic<int> counter{0};
std::vector<std::jthread> threads;
for (int i = 0; i < 8; ++i) {
    threads.emplace_back([&] {
        for (int j = 0; j < 1000; ++j) counter.fetch_add(1);
    });
}]=],

  [=[
void transfer(Account& from, Account& to, int amount) {
    std::scoped_lock lock(from.mutex, to.mutex);
    from.balance -= amount;
    to.balance += amount;
}]=],

  [=[
std::promise<int> promise;
std::future<int> result = promise.get_future();
std::thread worker([p = std::move(promise)]() mutable {
    p.set_value(compute_answer());
});
std::cout << result.get() << '\n';
worker.join();]=],

  [=[
std::unique_lock lock(mutex_);
if (!cv_.wait_for(lock, 2s, [this] { return ready_; })) {
    throw std::runtime_error("timed out waiting for worker");
}]=],

  [=[
std::jthread worker([](std::stop_token token) {
    while (!token.stop_requested()) {
        process_next();
    }
});
worker.request_stop();]=],

  [=[
std::generator<int> range(int lo, int hi) {
    for (int i = lo; i < hi; ++i) {
        co_yield i;
    }
}]=],

  ------------------------ time, random, files ------------------------

  [=[
auto start = std::chrono::steady_clock::now();
run_benchmark();
auto elapsed = std::chrono::steady_clock::now() - start;
auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(elapsed);
std::cout << "took " << ms.count() << "ms\n";]=],

  [=[
using namespace std::chrono_literals;
auto deadline = std::chrono::steady_clock::now() + 5s;
while (std::chrono::steady_clock::now() < deadline) {
    if (poll()) break;
    std::this_thread::sleep_for(50ms);
}]=],

  [=[
std::random_device rd;
std::mt19937 gen(rd());
std::uniform_int_distribution<int> dist(1, 6);
int roll = dist(gen);]=],

  [=[
std::ifstream file(path);
std::string line;
while (std::getline(file, line)) {
    if (line.empty() || line[0] == '#') continue;
    entries.push_back(parse_entry(line));
}]=],

  [=[
std::ofstream out("report.csv");
out << "name,score\n";
for (const auto& [name, score] : results) {
    out << name << ',' << score << '\n';
}]=],

  [=[
std::ifstream in(path, std::ios::binary);
std::vector<char> bytes((std::istreambuf_iterator<char>(in)),
                        std::istreambuf_iterator<char>());
std::cout << "read " << bytes.size() << " bytes\n";]=],

  [=[
namespace fs = std::filesystem;
for (const auto& entry : fs::recursive_directory_iterator(root)) {
    if (entry.is_regular_file() && entry.path().extension() == ".cpp") {
        sources.push_back(entry.path());
    }
}]=],

  [=[
const char* home = std::getenv("HOME");
std::filesystem::path config_dir = home ? home : "/tmp";
config_dir /= ".config/myapp";
std::filesystem::create_directories(config_dir);]=],

  [=[
for (std::size_t i = 0; i < data.size(); ++i) {
    std::printf("%02x%c", data[i], (i + 1) % 16 == 0 ? '\n' : ' ');
}]=],

  ------------------------ data structures ------------------------

  [=[
Node* reverse(Node* head) {
    Node* prev = nullptr;
    while (head) {
        Node* next = head->next;
        head->next = prev;
        prev = head;
        head = next;
    }
    return prev;
}]=],

  [=[
TreeNode* insert(TreeNode* root, int key) {
    if (!root) return new TreeNode{key};
    if (key < root->val) root->left = insert(root->left, key);
    else root->right = insert(root->right, key);
    return root;
}]=],

  [=[
int height(const TreeNode* node) {
    if (node == nullptr) return 0;
    return 1 + std::max(height(node->left), height(node->right));
}]=],

  [=[
std::vector<int> inorder(TreeNode* root) {
    std::vector<int> out;
    std::stack<TreeNode*> st;
    TreeNode* cur = root;
    while (cur || !st.empty()) {
        while (cur) { st.push(cur); cur = cur->left; }
        cur = st.top();
        st.pop();
        out.push_back(cur->val);
        cur = cur->right;
    }
    return out;
}]=],

  [=[
struct TrieNode {
    std::array<std::unique_ptr<TrieNode>, 26> next;
    bool terminal = false;
};

void insert(TrieNode* node, std::string_view word) {
    for (char c : word) {
        auto& child = node->next[c - 'a'];
        if (!child) child = std::make_unique<TrieNode>();
        node = child.get();
    }
    node->terminal = true;
}]=],

  [=[
struct DisjointSet {
    std::vector<int> parent, rank;
    explicit DisjointSet(int n) : parent(n), rank(n, 0) {
        std::iota(parent.begin(), parent.end(), 0);
    }
    int find(int x) {
        return parent[x] == x ? x : parent[x] = find(parent[x]);
    }
};]=],

  [=[
bool unite(int a, int b) {
    a = find(a);
    b = find(b);
    if (a == b) return false;
    if (rank[a] < rank[b]) std::swap(a, b);
    parent[b] = a;
    if (rank[a] == rank[b]) ++rank[a];
    return true;
}]=],

  [=[
class Range {
public:
    struct Iterator {
        int value;
        int operator*() const { return value; }
        Iterator& operator++() { ++value; return *this; }
        bool operator!=(Iterator o) const { return value != o.value; }
    };
    Range(int lo, int hi) : lo_(lo), hi_(hi) {}
    Iterator begin() const { return {lo_}; }
    Iterator end() const { return {hi_}; }

private:
    int lo_, hi_;
};]=],

  [=[
struct Matrix {
    std::size_t rows, cols;
    std::vector<double> data;
    Matrix(std::size_t r, std::size_t c) : rows(r), cols(c), data(r * c) {}
    double& operator()(std::size_t r, std::size_t c) {
        return data[r * cols + c];
    }
};]=],

  [=[
bool balanced(std::string_view s) {
    std::stack<char> st;
    for (char c : s) {
        if (c == '(' || c == '[' || c == '{') {
            st.push(c);
        } else if (c == ')' || c == ']' || c == '}') {
            char want = c == ')' ? '(' : c == ']' ? '[' : '{';
            if (st.empty() || st.top() != want) return false;
            st.pop();
        }
    }
    return st.empty();
}]=],

  ------------------------ graphs ------------------------

  [=[
std::queue<int> q;
std::vector<int> dist(n, -1);
dist[start] = 0;
q.push(start);
while (!q.empty()) {
    int u = q.front();
    q.pop();
    for (int v : adj[u]) {
        if (dist[v] == -1) {
            dist[v] = dist[u] + 1;
            q.push(v);
        }
    }
}]=],

  [=[
void dfs(int u, std::vector<bool>& seen, const Graph& g) {
    seen[u] = true;
    for (int v : g[u]) {
        if (!seen[v]) dfs(v, seen, g);
    }
}]=],

  [=[
using Edge = std::pair<int, int>;  // {weight, node}
std::priority_queue<Edge, std::vector<Edge>, std::greater<>> pq;
dist[src] = 0;
pq.emplace(0, src);
while (!pq.empty()) {
    auto [d, u] = pq.top();
    pq.pop();
    if (d > dist[u]) continue;
    for (auto [w, v] : adj[u]) {
        if (dist[u] + w < dist[v]) {
            dist[v] = dist[u] + w;
            pq.emplace(dist[v], v);
        }
    }
}]=],

  [=[
std::vector<int> indeg(n, 0), order;
for (int u = 0; u < n; ++u)
    for (int v : adj[u]) ++indeg[v];
std::queue<int> q;
for (int u = 0; u < n; ++u)
    if (indeg[u] == 0) q.push(u);
while (!q.empty()) {
    int u = q.front();
    q.pop();
    order.push_back(u);
    for (int v : adj[u])
        if (--indeg[v] == 0) q.push(v);
}]=],

  [=[
constexpr std::array<std::pair<int, int>, 4> kDirs{
    {{0, 1}, {1, 0}, {0, -1}, {-1, 0}}};
for (auto [dr, dc] : kDirs) {
    int nr = r + dr, nc = c + dc;
    if (nr < 0 || nc < 0 || nr >= rows || nc >= cols) continue;
    if (grid[nr][nc] == '#') continue;
    visit(nr, nc);
}]=],

  [=[
for (std::size_t i = 0; i < matrix.size(); ++i) {
    for (std::size_t j = 0; j < matrix[i].size(); ++j) {
        result[j][i] = matrix[i][j];
    }
}]=],

  ------------------------ searching and sorting ------------------------

  [=[
while (left <= right) {
    int mid = left + (right - left) / 2;
    if (nums[mid] == target) return mid;
    if (nums[mid] < target) left = mid + 1;
    else right = mid - 1;
}]=],

  [=[
int partition(std::vector<int>& a, int lo, int hi) {
    int pivot = a[hi];
    int i = lo;
    for (int j = lo; j < hi; ++j) {
        if (a[j] < pivot) std::swap(a[i++], a[j]);
    }
    std::swap(a[i], a[hi]);
    return i;
}]=],

  [=[
void merge_sort(std::vector<int>& a, int lo, int hi) {
    if (hi - lo < 2) return;
    int mid = lo + (hi - lo) / 2;
    merge_sort(a, lo, mid);
    merge_sort(a, mid, hi);
    std::inplace_merge(a.begin() + lo, a.begin() + mid, a.begin() + hi);
}]=],

  [=[
int left = 0, right = static_cast<int>(nums.size()) - 1;
while (left < right) {
    int sum = nums[left] + nums[right];
    if (sum == target) return {left, right};
    if (sum < target) ++left;
    else --right;
}]=],

  [=[
std::unordered_map<char, int> window;
int best = 0;
for (int lo = 0, hi = 0; hi < static_cast<int>(s.size()); ++hi) {
    ++window[s[hi]];
    while (window[s[hi]] > 1) --window[s[lo++]];
    best = std::max(best, hi - lo + 1);
}]=],

  ------------------------ dynamic programming ------------------------

  [=[
std::vector<int> dp(n + 1, 0);
dp[1] = 1;
for (int i = 2; i <= n; ++i) {
    dp[i] = dp[i - 1] + dp[i - 2];
}]=],

  [=[
for (int i = 1; i <= n; ++i) {
    for (int j = 1; j <= m; ++j) {
        if (a[i - 1] == b[j - 1]) {
            dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
            dp[i][j] = std::max(dp[i - 1][j], dp[i][j - 1]);
        }
    }
}]=],

  [=[
std::vector<int> best(capacity + 1, 0);
for (const auto& item : items) {
    for (int w = capacity; w >= item.weight; --w) {
        best[w] = std::max(best[w], best[w - item.weight] + item.value);
    }
}]=],

  [=[
std::unordered_map<long long, long long> memo;
long long collatz_len(long long n) {
    if (n == 1) return 1;
    if (auto it = memo.find(n); it != memo.end()) return it->second;
    long long next = n % 2 == 0 ? n / 2 : 3 * n + 1;
    return memo[n] = 1 + collatz_len(next);
}]=],

  [=[
int best = nums[0], current = 0;
for (int x : nums) {
    current = std::max(x, current + x);
    best = std::max(best, current);
}]=],

  [=[
std::vector<long long> prefix(n + 1, 0);
for (int i = 0; i < n; ++i) {
    prefix[i + 1] = prefix[i] + values[i];
}
auto range_sum = [&](int l, int r) { return prefix[r + 1] - prefix[l]; };]=],

  ------------------------ math and bits ------------------------

  [=[
long long gcd(long long a, long long b) {
    while (b != 0) {
        a %= b;
        std::swap(a, b);
    }
    return a;
}]=],

  [=[
std::vector<bool> is_prime(limit + 1, true);
is_prime[0] = is_prime[1] = false;
for (int i = 2; i * i <= limit; ++i) {
    if (!is_prime[i]) continue;
    for (int j = i * i; j <= limit; j += i) is_prime[j] = false;
}]=],

  [=[
using u64 = std::uint64_t;
u64 mod_pow(u64 base, u64 exp, u64 mod) {
    u64 result = 1;
    base %= mod;
    while (exp > 0) {
        if (exp & 1) result = result * base % mod;
        base = base * base % mod;
        exp >>= 1;
    }
    return result;
}]=],

  [=[
bool is_power_of_two(std::uint32_t x) { return x && !(x & (x - 1)); }

int popcount(std::uint32_t x) {
    int count = 0;
    for (; x; x &= x - 1) ++count;
    return count;
}]=],

  [=[
enum Permissions : unsigned {
    Read    = 1u << 0,
    Write   = 1u << 1,
    Execute = 1u << 2,
};
unsigned perms = Read | Write;
if (perms & Write) save(document);]=],

  [=[
[[nodiscard]] std::size_t hash_combine(std::size_t seed, std::size_t v) {
    return seed ^ (v + 0x9e3779b9 + (seed << 6) + (seed >> 2));
}]=],

  [=[
for (int i = 0; i < n; ++i)
    for (int k = 0; k < n; ++k)
        for (int j = 0; j < n; ++j)
            c[i][j] += a[i][k] * b[k][j];]=],

  [=[
double distance(Point a, Point b) {
    return std::hypot(b.x - a.x, b.y - a.y);
}
double angle = std::atan2(dir.y, dir.x) * 180.0 / std::numbers::pi;]=],

  [=[
namespace geometry {
constexpr double kEpsilon = 1e-9;
inline bool nearly_equal(double a, double b) {
    return std::abs(a - b) < kEpsilon;
}
}  // namespace geometry]=],

  ------------------------ games ------------------------

  [=[
while (running) {
    auto now = clock::now();
    float dt = std::chrono::duration<float>(now - last).count();
    last = now;
    handle_input();
    world.update(dt);
    renderer.draw(world);
}]=],

  [=[
for (auto& e : entities) {
    e.velocity += gravity * dt;
    e.position += e.velocity * dt;
    if (e.position.y < 0.0f) {
        e.position.y = 0.0f;
        e.velocity.y *= -0.5f;
    }
}]=],

  [=[
bool intersects(const AABB& a, const AABB& b) {
    return a.min.x <= b.max.x && a.max.x >= b.min.x &&
           a.min.y <= b.max.y && a.max.y >= b.min.y;
}]=],

  [=[
constexpr float lerp(float a, float b, float t) { return a + (b - a) * t; }
float alpha = std::clamp(elapsed / duration, 0.0f, 1.0f);
float x = lerp(start_x, end_x, alpha);]=],

  [=[
enum class State { Idle, Running, Jumping, Falling };

void Player::update() {
    switch (state_) {
        case State::Idle:
            if (input.jump) state_ = State::Jumping;
            break;
        case State::Jumping:
            if (velocity_.y < 0) state_ = State::Falling;
            break;
        default:
            break;
    }
}]=],

  ------------------------ parsing ------------------------

  [=[
switch (token.kind) {
    case TokenKind::Plus:  return lhs + rhs;
    case TokenKind::Minus: return lhs - rhs;
    case TokenKind::Star:  return lhs * rhs;
    default: throw std::runtime_error("unexpected token");
}]=],

  [=[
std::vector<Token> tokens;
for (std::size_t i = 0; i < src.size();) {
    if (std::isspace(src[i])) { ++i; continue; }
    if (std::isdigit(src[i])) {
        std::size_t j = i;
        while (j < src.size() && std::isdigit(src[j])) ++j;
        tokens.push_back({TokenKind::Number, src.substr(i, j - i)});
        i = j;
    } else {
        tokens.push_back({TokenKind::Symbol, src.substr(i++, 1)});
    }
}]=],

  [=[
int Parser::expr() {
    int value = term();
    while (peek() == '+' || peek() == '-') {
        char op = next();
        int rhs = term();
        value = op == '+' ? value + rhs : value - rhs;
    }
    return value;
}]=],

  ------------------------ preprocessor and headers ------------------------

  [=[
#ifndef GAME_ENTITY_H
#define GAME_ENTITY_H

#include <cstdint>

struct Entity {
    std::uint32_t id;
    float x, y;
};

#endif  // GAME_ENTITY_H]=],

  [=[
#pragma once

#include <memory>
#include <string>

class Texture;

class Sprite {
public:
    explicit Sprite(std::shared_ptr<Texture> texture);
    void set_position(float x, float y);
};]=],

  [=[
#if defined(_WIN32)
    #define PLATFORM_NAME "windows"
#elif defined(__APPLE__)
    #define PLATFORM_NAME "macos"
#else
    #define PLATFORM_NAME "linux"
#endif]=],

  [=[
#define CHECK(cond)                                         \
    do {                                                    \
        if (!(cond)) fail(#cond, __FILE__, __LINE__);       \
    } while (0)]=],

  [=[
extern "C" {
int plugin_init(const char* name);
void plugin_shutdown(void);
}]=],

  [=[
namespace app::net {
using Bytes = std::vector<std::uint8_t>;
Bytes encode(const Message& msg);
}  // namespace app::net]=],

  ------------------------ tests ------------------------

  [=[
TEST(StackTest, PopReturnsLastPushed) {
    Stack<int> s;
    s.push(1);
    s.push(2);
    EXPECT_EQ(s.pop(), 2);
    EXPECT_FALSE(s.empty());
}]=],

  [=[
void test_split() {
    auto parts = split("a,b,,c", ',');
    assert(parts.size() == 4);
    assert(parts[2].empty());
    std::puts("test_split passed");
}]=],
}
